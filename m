From: Michael Renzmann <mrenzmann@web.de>
Subject: Re: Required resources on network driver programming
Date: Mon, 20 Dec 2004 10:06:09 +0100
Message-ID: <41C69601.7000202@web.de>
References: <20041220074535.64217.qmail@web52208.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: linux lover <linux_lover2004@yahoo.com>
In-Reply-To: <20041220074535.64217.qmail@web52208.mail.yahoo.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

linux lover wrote:
>                  I require help about where can i get
> resources or any book for writing virtual network
> driver with SAMPLE EXAMPLES?

I think the following resources might be useful for your task - also 
there might be alternatives for the implementation 
(tcpdump/tethereal-like programs that capture the information you need 
from a packet socket):

Linux Device Drivers, 2nd Edition
http://www.xml.com/ldd/chapter/book/index.html

The Linux Kernel Module Programming Guide
http://en.tldp.org/LDP/lkmpg/

Virtual Network Interfaces
http://www.linux.it/~rubini/docs/vinter/vinter.html

Linux Kernel Module Programming Guide
http://oopweb.com/OS/Documents/LKMPG/VolumeFrames.html?/OS/Documents/LKMPG/Volume/node11.html

The Linux Kernel API
http://kernelnewbies.org/documents/kdoc/kernel-api/linuxkernelapi.html


Generally it's also a good idea to have a look at 
http://www.kernelnewbies.org/ and visit the IRC-channel #kernelnewbies 
at oftc.net.

Bye, Mike
