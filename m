From: "Eble, Dan" <DanE@aiinet.com>
Subject: serial port-to-netdevice tap
Date: Tue, 15 Jun 2004 11:50:01 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C060DFCD9697A842B3189B458524FDC205D2C9@AIMAIL1.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A coworker of mine wants an easy way to monitor data transfer and control
line changes on an serial port.  His first impulse was to create a /proc
file, but I suggested a netlink socket, or even a raw net device so that he
can take advantage of libpcap for some pretty powerful filtering.  Does
anything like this exist already?

-- 
Dan Eble <dane@aiinet.com>  _____  .
Software Engineer          |  _  |/|
Applied Innovation Inc.    | |_| | |
http://www.aiinet.com/     |__/|_|_|
