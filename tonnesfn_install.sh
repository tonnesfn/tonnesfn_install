#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 
  exit 1
else
  echo "Updating and Upgrading"
  apt-get update && sudo apt-get upgrade -y

sudo apt-get install dialog
  cmd=(dialog --separate-output --checklist "Please Select Software you want to install:" 22 76 16)
  options=(1 "Various small programs" off
           2 "Git++" off
           3 "Chrome" off
           4 "ROS" off
           5 "GVIM" off
           6 "Get DyRET code" off)
  choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
  for choice in $choices
  do
  case $choice in

  1) # Misc programs
    echo "Installing VLC"
    apt-get install vlc -y
    echo "Installing Slack"
    snap install slack --classic
    echo "Installing Terminator"
    apt-get install terminator -y
  ;;

  2) # Install Git++
    echo "Installing Git"

    # Install git
    apt install git -y

    # Install GitKraken
    echo "Installing GitKraken"
    apt-get install libgnome-keyring-common libgnome-keyring-dev -y
    wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
    dpkg -i --force-depends gitkraken-amd64.deb
    apt-get install -f -y
    rm -f gitkraken-amd64.deb

    # Configure Git
    git config --global user.email "tonnes.nygaard@gmail.com"
    git config --global user.name $SUDO_USER

    # Make keys and open
    sudo -H -u $SUDO_USER bash -c 'mkdir $HOME/.ssh'
    sudo -H -u $SUDO_USER bash -c 'ssh-keygen -t rsa -b 4096 -C "tonnes.nygaard@gmail.com" -f $HOME/.ssh/id_rsa'
    sudo -H -u $SUDO_USER bash -c 'eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_rsa' 
    gedit ~/.ssh/id_rsa.pub &
  ;;

  3) # Chrome
    echo "Installing Google Chrome"
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    apt-get update 
    apt-get install google-chrome-stable -y
    echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
  ;;

  4) # ROS
    sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
    apt-get update
    apt-get install ros-melodic-desktop-full -y
    rosdep init
    rosdep update
    apt-get install python-rosinstall python-rosinstall-generator python-wstool build-essential -y

    wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
    apt-get update
    apt-get install python-catkin-tools -y
    
    sudo -H -u $SUDO_USER bash -c 'mkdir -p ~/catkin_ws/src && source /opt/ros/melodic/setup.bash  && cd ~/catkin_ws && catkin build' 
    echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
  ;;

  5) # GVIM
    apt-get install vim-gnome -y
    #TODO: Add gvim settings
  ;;

  6) # Get DyRET git repos
    sudo -H -u $SUDO_USER bash -c 'cd ~/catkin_ws/src && git clone git@github.uio.no:robin/dyret_common.git'
    sudo -H -u $SUDO_USER bash -c 'cd ~/catkin_ws/src && git clone git@github.uio.no:robin/dyret_controller.git'
    sudo -H -u $SUDO_USER bash -c 'cd ~/catkin_ws/src && git clone git@github.uio.no:robin/dyret_hardware.git'
    sudo -H -u $SUDO_USER bash -c 'cd ~/catkin_ws/src && git clone git@github.uio.no:tonnesfn/tonnesfn_experiments.git'
    sudo -H -u $SUDO_USER bash -c 'cd ~/catkin_ws/src && git clone git@github.uio.no:robin/dyret_simulation.git'

  ;;

  esac
  done
fi
