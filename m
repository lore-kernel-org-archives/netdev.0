From: "James H. Cloos Jr." <cloos@jhcloos.com>
Subject: e100 in 2.5.59 through 2.5.61
Date: 16 Feb 2003 17:25:06 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3lm0fdfst.fsf@lugabout.jhcloos.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have been unable to get the e100 on the (actiontec) mini-pci card in
my laptop to work at 100baseT.  It was fine when I last booted a 2.4
kernel, and from fiddling with ethtool I've found that it works fine
at 10baseT half or full duplex, provided I configure autoneg off.

The switch is fine with other 100 devices, such as the printer and the
802.11 gateway.  It is also happy with the 3com card in the laptop's
port duplicator.

The cables say they are verified for gigabit ethernet, so I doubt they
are the problem.

Both the e100 and the eepro100 modules fail at 100baseT.

Has anyone else seen this?  Any thoughts on it?

I've no real need right now for 100, but it is a bit of a pain....

-JimC
