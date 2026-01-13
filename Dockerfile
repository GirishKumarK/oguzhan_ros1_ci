FROM osrf/ros:noetic-desktop-full-focal

# Tell the container to use the C.UTF-8 locale for its language settings
ENV LANG C.UTF-8

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections


# Install required packages
RUN set -x \
    && apt-get update \
    && apt-get --with-new-pkgs upgrade -y \
    && apt-get install -y git \
    && apt-get install -y ros-noetic-turtlebot3 \
    && apt-get install -y ros-noetic-turtlebot3-bringup ros-noetic-turtlebot3-description \
    && apt-get install -y ros-noetic-turtlebot3-example ros-noetic-turtlebot3-gazebo \
    && apt-get install -y ros-noetic-turtlebot3-msgs ros-noetic-turtlebot3-navigation \
    && apt-get install -y ros-noetic-turtlebot3-simulations \
    && apt-get install -y ros-noetic-turtlebot3-slam ros-noetic-turtlebot3-teleop \
    && apt-get install -y ros-noetic-gmapping ros-noetic-slam-gmapping ros-noetic-openslam-gmapping \ 
    && rm -rf /var/lib/apt/lists/*

# Link python3 to python otherwise ROS scripts fail when using the OSRF contianer
RUN ln -s /usr/bin/python3 /usr/bin/python

# Set up the catkin workspace
WORKDIR /
RUN mkdir -p /simulation_ws/src
WORKDIR /simulation_ws/src


# !!!!! NOTE !!!!!
# Clone tortoisebot_waypoint from github !
RUN git clone https://github.com/grboguz21/tortoisebot_wp .
COPY tortoisebot/ /simulation_ws/src/tortoisebot/



# build
WORKDIR /simulation_ws
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && catkin_make"

# replace setup.bash in ros_entrypoint.sh
RUN sed -i 's|source "/opt/ros/\$ROS_DISTRO/setup.bash"|source "/simulation_ws/devel/setup.bash"|g' /ros_entrypoint.sh

# Set up the Network Configuration
# Example with the ROS_MASTER_URI value set as the one running on the Host System
# ENV ROS_MASTER_URI http://1_simulation:11311

# Cleanup
RUN rm -rf /root/.cache

# Start a bash shell when the container starts
CMD ["bash"]



# FROM osrf/ros:noetic-desktop-full-focal

# ENV LANG C.UTF-8

# RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# # -----------------------------
# # System & ROS dependencies
# # -----------------------------
# RUN set -x \
#     && apt-get update \
#     && apt-get upgrade -y \
#     && apt-get install -y \
#         git \
#         python3-catkin-tools \
#         python3-rosdep \
#         python3-vcstool \
#         ros-noetic-gazebo-ros \
#         ros-noetic-gazebo-ros-control \
#         ros-noetic-xacro \
#         ros-noetic-joint-state-publisher \
#         ros-noetic-joint-state-publisher-gui \
#         ros-noetic-robot-state-publisher \
#         ros-noetic-controller-manager \
#         ros-noetic-diff-drive-controller \
#     && rm -rf /var/lib/apt/lists/*

# # Python symlink (ROS script compatibility)
# RUN ln -s /usr/bin/python3 /usr/bin/python

# # -----------------------------
# # Catkin workspace
# # -----------------------------
# WORKDIR /simulation_ws
# RUN mkdir -p src
# WORKDIR /simulation_ws/src

# # -----------------------------
# # TortoiseBot Simulation (ROS1)
# # -----------------------------
# COPY tortoisebot /simulation_ws/src/tortoisebot

# # # -----------------------------
# # # Waypoint (Checkpoint 23) !!!
# # # -----------------------------
# # RUN git clone https://github.com/rigbetellabs/tortoisebot_waypoint.git

# # -----------------------------
# # Build workspace
# # -----------------------------
# WORKDIR /simulation_ws
# RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && catkin_make"

# # -----------------------------
# # Source workspace automatically
# # -----------------------------
# RUN sed -i 's|source "/opt/ros/\$ROS_DISTRO/setup.bash"|source "/simulation_ws/devel/setup.bash"|g' /ros_entrypoint.sh

# # Cleanup
# RUN rm -rf /root/.cache

# CMD ["bash"]
