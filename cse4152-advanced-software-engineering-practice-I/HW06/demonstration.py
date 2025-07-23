import gym
import os
import numpy as np
import pygame
import copy
import re
import gym.envs.box2d.car_racing as cr

def load_demonstrations ( path ):
    """
    A : Implement loading demonstrations

    Given the folder containing the expert demonstrations, the data gets loaded and
    stored it in two lists: observations and actions.
                    N = number of (observation, action) - pairs
    data_folder:    python string, the path to the folder containing the
                    observation_%05d.npy and action_%05d.npy files
    return:
    observations:   python list of N numpy.ndarrays of size (96, 96, 3)
    actions:        python list of N numpy.ndarrays of size 3
    """
    observations = []
    actions = []

    files = os.listdir(path)
    obs_files_string = [f for f in files if re.match(r'^state_\d+\.npy$', f)]
    for obs_str in obs_files_string :
        obsPath = os.path.join(path, obs_str)
        observations.append(np.load(obsPath))

    action_files_string = [f for f in files if re.match(r'^action_\d+\.npy$', f)]
    for act_str in action_files_string :
        actPath = os.path.join(path, act_str)
        actions.append(np.load(actPath))

    # print("list length : ", len(observations), len(actions))
    return observations, actions




def store_demonstrations ( path, actions, states ):


    if not os.path.exists(path):
        os.makedirs(path)

    frame_n = len (states)
    frames = [int(filename[6:-4]) for filename in os.listdir(path) if filename.startswith('state')]
    if len (frames) > 0:
        start_index = max(frames) + 1
    else:
        start_index = 0

    for i in range(frame_n):
        print( "storing %dth frame (%d/%d) " % (i+start_index,i,frame_n) )
        np.save(os.path.join(path, f"state_{start_index + i}.npy"), states[i], allow_pickle=True)
        np.save(os.path.join(path, f"action_{start_index +i}.npy" ), np.array(actions[i]), allow_pickle=True)
    
    pass

def record_demonstration ( path ):

    print("Record demonstration.")
    print("key s - store the trajectory and start next recording.")
    print("key r - restart without recording.")
    print("key q - quit.")

    action = np.array([0.0, 0.0, 0.0])
    import pygame 

    global retry
    retry = False
    global record
    record = False
    global quit
    quit = False

    def register_input():

        for event in pygame.event.get():
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_LEFT:
                    action[0] = -1.0
                if event.key == pygame.K_RIGHT:
                    action[0] = +1.0
                if event.key == pygame.K_UP:
                    action[1] = +0.5
                if event.key == pygame.K_DOWN:
                    action[2] = +0.8  # set 1.0 for wheels to block to zero rotation
                if event.key == pygame.K_r:
                    global retry
                    retry = True
                if event.key == pygame.K_s:
                    global record
                    record = True
                if event.key == pygame.K_q:
                    global quit
                    quit = True

            if event.type == pygame.KEYUP:
                if event.key == pygame.K_LEFT and action[0] < 0.0:
                    action[0] = 0
                if event.key == pygame.K_RIGHT and action[0] > 0.0:
                    action[0] = 0
                if event.key == pygame.K_UP:
                    action[1] = 0
                if event.key == pygame.K_DOWN:
                    action[2] = 0

    #env = gym.make("CartPole-v1")
    env = cr.CarRacing(render_mode="human")

    isopen = True
    keyframe = 10

    while isopen:
        states = []
        actions = []
        state = env.reset() [0]
        env.render()
        total_reward = 0.0
        steps = 0
        retry = False
        quit = False
        record = False

        while True:
            
            register_input()

            # record trajectory (action and state)
            if steps % keyframe == 0:
                states.append(copy.copy(state))
                actions.append(copy.copy(action))

            # action
            s, r, done, info, _ = env.step(action)
            state = s
            total_reward += r

            # render scene
            isopen = env.render()
            steps += 1
            if done or retry or quit or record or (isopen is False):
                break

        if record or done:
            store_demonstrations ( path, actions, states )
            print(total_reward)
            record = False
        
        if quit:
            break

    env.close()
    
