From: Sunil Shahu <shshahu@gmail.com>
Subject: Need direction to understand mac80211
Date: Wed, 27 Jan 2016 10:52:25 +0530
Message-ID: <1453872145.4956.3.camel@sunil.sibshivalik.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am currently working on an project that aims to provide multiple 802.11ac radio support on a single node for mesh network. In this both the radios will operate in different channel and will talk to different nodes in mesh network.

I need to work with kernel mac80211 driver subsystem for the same. I went through different documentation to understand the theories of 802.11s which can help during working on mac80211 driver. However I am not able to understand the source code properly. 

Can you please provide some guidance to understand mac80211 and related networking stack in Linux kernel.

I am looking for 
1) How to create bridge bridge for two Phy radios during initialization/packet forwarding?
2) Also, need some idea about how packets will be routed in mesh_hwmp.
3) How the path request and response should behave in this case?
4) Will there be any changes for mesh path table entries?

Any suggestion for document/book/blog will be great help.

I already went through following materials.
http://kernelnewbies.org/Documents/Kernel-Docbooks?action=AttachFile&do=get&target=mac80211_2.6.29.pdf
http://www.campsmur.cat/files/mac80211_intro.pdf
https://www.cwnp.com/uploads/802-11s_mesh_networking_v1-0.pdf
http://www.ieee802.org/802_tutorials/06-November/802.11s_Tutorial_r5.pdf

Any suggestion and directions will be great help.

Thanks,
Sunil Shahu.
