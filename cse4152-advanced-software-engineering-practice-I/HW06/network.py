import torch
import numpy as np

import torch.nn as nn
import torch.nn.functional as F

class ClassificationNetworkColors(torch.nn.Module):
    def __init__(self):

        super().__init__()
        # setting device on GPU if available, else CPU
        device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

        self.classes = [[-1., 0., 0.],  # left
                        [-1., 0.5, 0.], # left and accelerate
                        [-1., 0., 0.8], # left and brake
                        [1., 0., 0.],   # right
                        [1., 0.5, 0.],  # right and accelerate
                        [1., 0., 0.8],  # right and brake
                        [0., 0., 0.],   # no input
                        [0., 0.5, 0.],  # accelerate
                        [0., 0., 0.8]]  # brake

        """
        D : Network Implementation

        Implementation of the network layers. 
        The image size of the input observations is 96x96 pixels.

        Using torch.nn.Sequential(), implement each convolution layers and Linear layers
        """

        # convolution layers 
        self.conv1 = nn.Sequential(
            nn.Conv2d(in_channels=3, out_channels=32,  kernel_size=3),
            # nn.BatchNorm2d(32),
            nn.LeakyReLU(negative_slope= 0.2, inplace=True),
            nn.AvgPool2d(2)                                            
        )
        self.conv2 = nn.Sequential(
            nn.Conv2d(in_channels=32, out_channels=64,  kernel_size=3),
            # nn.BatchNorm2d(64),
            nn.LeakyReLU(negative_slope= 0.2, inplace=True),
            nn.AvgPool2d(2)                                            
        )
        self.conv3 = nn.Sequential(
            nn.Conv2d(in_channels=64, out_channels=64, kernel_size=3), 
            # nn.BatchNorm2d(64),
            nn.LeakyReLU(negative_slope=0.2, inplace=True),
            nn.AvgPool2d(2)                                             
        )

        # Linear layers (output size : 9)
        self.linear = nn.Sequential(
            nn.Linear(6400, 512),
            nn.LeakyReLU(negative_slope=0.2, inplace=True),
            nn.Linear(512, 9),
            nn.LeakyReLU(negative_slope=0.2, inplace=True),
            nn.Linear(128, 9),
            nn.LeakyReLU(negative_slope=0.2, inplace=True)
        )

    def forward(self, observation):
        """

        D : Network Implementation

        The forward pass of the network. 
        Returns the prediction for the given input observation.
        observation:   torch.Tensor of size (batch_size, 96, 96, 3)
        return         torch.Tensor of size (batch_size, C)

        """
        observation = observation.permute(0, 3, 1, 2)
        tmp = self.conv1(observation)
        tmp = self.conv2(tmp)
        tmp = self.conv3(tmp)

        tmp = tmp.reshape(tmp.size(0), -1)
        tmp = self.linear(tmp)
        return tmp

        pass 

    def actions_to_classes(self, actions):
        """
        C : Conversion from action to classes

        For a given set of actions map every action to its corresponding
        action-class representation. Every action is represented by a 1-dim vector 
        with the entry corresponding to the class number.
        actions:        python list of N torch.Tensors of size 3
        return          python list of N torch.Tensors of size 1
        """
        classIndicies = []        
        for action in actions :
            action = action.tolist()
            
            if action[2] - 0.8 > 0 :
                action[2] = 0.8
                   
            findI = self.classes.index(action)
            # print("################",findI)
            toTensor = torch.tensor([findI])
            classIndicies.append(toTensor)

        return classIndicies

    def scores_to_action(self, scores):
        """
        C : Selection of action from scores

        Maps the scores predicted by the network to an action-class and returns
        the corresponding action [steer, gas, brake].
                        C = number of classes
        scores:         python list of torch.Tensors of size C
        return          (float, float, float)
        """
        max_index = max(range(len(scores[0])), key=lambda i: scores[0][i].item())
        return self.classes[max_index]