From: sinder@thp.Uni-Koeln.DE (Andreas Sindermann)
Subject: Options for forcedeth Linux kernel module
Date: Sat, 13 Nov 2004 20:13:35 +0100
Message-ID: <200411131913.iADJDZ321996@sun80.thp.Uni-Koeln.DE>
Cc: c-d.hailfinger.kernel.2004@gmx.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm searching for options (for modules.conf) of the forcedeth kernel
module. I'm using the Suse 9.2 version which seems to be  0.29. 

On http://www.hailfinger.org/carldani/linux/patches/forcedeth/ I can't
find any information how to explicity set options for 100 Mbps full
duplex. 

Currently the driver sets the network device to 100 Mbps half duplex
which results in extremely poor performance (only a few KB/sec
throughput) since our network switch is configured with full duplex
explicitely (and we can't change it because Sun workstations won't
work properly otherwise).

I've looked into the sourced and searched google but unfortunately 
without success. A short hint to a source of information would be of
great help.

Thanks in advance
Andreas
