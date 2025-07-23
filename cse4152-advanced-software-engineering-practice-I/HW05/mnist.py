import argparse
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torchvision import datasets, transforms
from torch.optim.lr_scheduler import StepLR
import time

# Define a custom neural network class called 'Net'.
class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()

        # Define the first fully connected (linear) layer with 784 input features and 50 output features.
        self.fc1 = nn.Linear(28*28, 50)

        # Define the second fully connected layer with 50 input features and 50 output features.
        self.fc2 = nn.Linear(50, 50)

        # Define the third fully connected layer with 50 input features and 10 output features.
        self.fc3 = nn.Linear(50, 10)
    
    def forward(self, x):

        ##############################################################################
        # (TODO: Add description)                                                    #
        # This comment should be filled with a brief description of the operation.   #
        # Forward pass of the neural network. Fill in step 1~5                       #
        ##############################################################################

        # Flatten the input image from 28x28 pixels to a 1D tensor with 784 elements.
        x = x.view(-1, 28*28)  # The -1 maintains the batch size while automatically adjusting the other dimensions.

        # step1. Pass through the first fully connected layer (fc1) to perform a linear transformation.
        x = self.fc1(x)

        # step2. Apply the Rectified Linear Unit (ReLU) activation function to introduce non-linearity.
        x = F.relu(x)

        # step3. Pass through the second fully connected layer (fc2) to perform another linear transformation.
        x = self.fc2(x)

        # step4. Apply ReLU activation once again.
        x = F.relu(x)

        # step5. Pass through the third fully connected layer (fc3) to perform a linear transformation.
        x = self.fc3(x)

        # Use the "log_softmax function" to convert the output into probability values.
        output = F.log_softmax(x, dim=1)
        
        # Return the computed output.
        return output


# This function is responsible for training the model.
def train(args, model, device, train_loader, optimizer, epoch):
    # Set the model in training mode to enable gradient computation and parameter updates.
    model.train()
    
    # Iterate through the training data in batches.
    for batch_idx, (data, target) in enumerate(train_loader):
        # Move the data and target to the specified device
        data, target = data.to(device), target.to(device)
        
        # Reset the gradients of the model's parameters.
        optimizer.zero_grad()
        
        # Forward pass: Compute the output of the model for the current batch of data.
        output = model(data)
        
        # Calculate the negative log-likelihood (NLL) loss between the model's output and the target.
        loss = F.nll_loss(output, target)
        
        # Backpropagate the gradients through the model.
        loss.backward()
        
        # Update the model's parameters using the optimizer.
        optimizer.step()
        
        # Print training progress at specified intervals.
        if batch_idx % args.log_interval == 0:
            print('Train Epoch: {} [{}/{} ({:.0f}%)]\tLoss: {:.6f}'.format(
                epoch, batch_idx * len(data), len(train_loader.dataset),
                100. * batch_idx / len(train_loader), loss.item()))
            
            # If the 'dry_run' flag is set in the arguments, exit the loop to perform a dry run (useful for debugging).
            if args.dry_run:
                break


def test(model, device, test_loader):
    # Set the model in evaluation mode, disabling gradient computation and parameter updates.
    model.eval()
    
    # Initialize variables to track test loss and correct predictions.
    test_loss = 0
    correct = 0
    
    # Disable gradient computation for the following code block.
    with torch.no_grad():
        # Iterate through the test data in batches.
        for data, target in test_loader:
            # Move the data and target to the specified device (e.g., GPU).
            data, target = data.to(device), target.to(device)
            
            # Forward pass: Compute the output of the model for the current batch of test data.
            output = model(data)
            
            # Calculate the NLL loss between the model's output and the target and sum it up.
            test_loss += F.nll_loss(output, target, reduction='sum').item()
            
            # Get the predicted class by finding the index of the maximum log-probability in the output.
            pred = output.argmax(dim=1, keepdim=True)
            
            # Check if the predicted class matches the target class and count correct predictions.
            correct += pred.eq(target.view_as(pred)).sum().item()
    
    # Calculate the average test loss.
    test_loss /= len(test_loader.dataset)
    
    # Print the test results, including the average loss and accuracy.
    print('\nTest set: Average loss: {:.4f}, Accuracy: {}/{} ({:.0f}%)\n'.format(
        test_loss, correct, len(test_loader.dataset),
        100. * correct / len(test_loader.dataset))
    )


def main():
    # Training settings
    parser = argparse.ArgumentParser(description='PyTorch MNIST Example')
    parser.add_argument('--batch-size', type=int, default=64, metavar='N',
                        help='input batch size for training (default: 64)')
    parser.add_argument('--test-batch-size', type=int, default=1000, metavar='N',
                        help='input batch size for testing (default: 1000)')
    parser.add_argument('--epochs', type=int, default=5, metavar='N',
                        help='number of epochs to train (default: 5)')
    parser.add_argument('--lr', type=float, default=0.003, metavar='LR',
                        help='learning rate (default: 0.003)')
    parser.add_argument('--gamma', type=float, default=0.7, metavar='M',
                        help='Learning rate step gamma (default: 0.7)')
    parser.add_argument('--no-cuda', action='store_true', default=False,
                        help='disables CUDA training')
    parser.add_argument('--no-mps', action='store_true', default=False,
                        help='disables macOS GPU training')
    parser.add_argument('--dry-run', action='store_true', default=False,
                        help='quickly check a single pass')
    parser.add_argument('--seed', type=int, default=1, metavar='S',
                        help='random seed (default: 1)')
    parser.add_argument('--log-interval', type=int, default=10, metavar='N',
                        help='how many batches to wait before logging training status')
    parser.add_argument('--save-model', action='store_true', default=False,
                        help='For Saving the current Model')
    args = parser.parse_args()
    use_cuda = not args.no_cuda and torch.cuda.is_available()
    use_mps = not args.no_mps and torch.backends.mps.is_available()

    torch.manual_seed(args.seed)

    if use_cuda:
        device = torch.device("cuda")
    elif use_mps:
        device = torch.device("mps")
    else:
        device = torch.device("cpu")

    train_kwargs = {'batch_size': args.batch_size}
    test_kwargs = {'batch_size': args.test_batch_size}
    if use_cuda:
        cuda_kwargs = {'num_workers': 1,
                       'pin_memory': True,
                       'shuffle': True}
        train_kwargs.update(cuda_kwargs)
        test_kwargs.update(cuda_kwargs)

    transform=transforms.Compose([
        transforms.ToTensor(),
        transforms.Normalize((0.1307,), (0.3081,))
        ])
    
    # Load the MNIST dataset for training and testing
    dataset1 = datasets.MNIST('../data', train=True, download=True,
                       transform=transform)
    dataset2 = datasets.MNIST('../data', train=False,
                       transform=transform)
    
    # Create data loaders for training and testing data
    train_loader = torch.utils.data.DataLoader(dataset1,**train_kwargs)
    test_loader = torch.utils.data.DataLoader(dataset2, **test_kwargs)

    # Create an instance of the neural network model (Net) and move it to the specified device
    model = Net().to(device)

    # Define the optimizer (Stochastic Gradient Descent) and set the learning rate based on the provided argument
    optimizer = optim.SGD(model.parameters(), lr=args.lr)

    # Create a learning rate scheduler that reduces the learning rate based on a step size and gamma
    scheduler = StepLR(optimizer, step_size=1, gamma=args.gamma)

    start_time = time.time()

    # Iterate through training epochs
    for epoch in range(1, args.epochs + 1):
        # Train the model for the current epoch using the 'train' function
        train(args, model, device, train_loader, optimizer, epoch)
        # Test the model's performance on the test dataset using the 'test' function
        test(model, device, test_loader)

        # Adjust the learning rate based on the scheduler
        scheduler.step()
    
    end_time = time.time()

    total_time = end_time - start_time
    print(f"Total training and evaluation time: {total_time:.4f} 초")

    torch.save(model, "mnist_agent.pt")
    torch.cuda.empty_cache()


if __name__ == '__main__':
    main()