From: Hendrik Wiese <7.e.Q@syncro-community.de>
Subject: driver ability to use iptables?
Date: Mon, 15 Nov 2004 13:32:14 +0100
Message-ID: <4198A1CE.7040905@syncro-community.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello there,

I hope I do right posting this here. So please don't be angry if I'm 
wrong. I'm kind of newbie.

We developed a driver which puts an IP-layer onto the VME-bus. So we are 
able to do normal
network traffic over the VME-bus, transfer files between active VME 
modules and so on. But
as soon as we want to use iptables to establish one of the modules as a 
router to the outer world
(tp network connected via front panel eth device) this doesn't work... 
everything is configured
correctly as it works for to eth devices. Is there any ability else a 
network device driver must
have to work with iptables?

Thanks in advance

kind regards
Hendrik (Germany)

PS: kernel is version 2.6.7, System is an LFS 5
