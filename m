From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Kernel BUG: Qos seg. fault
Date: Mon, 24 May 2004 21:19:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524211958.A3940@electric-eye.fr.zoreil.com>
References: <40B1E325.80408@upf.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jaume Catarineu <jaume.catarineu@upf.edu>
Content-Disposition: inline
In-Reply-To: <40B1E325.80408@upf.edu>; from jaume.catarineu@upf.edu on Mon, May 24, 2004 at 11:57:25AM +0000
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jaume Catarineu <jaume.catarineu@upf.edu> :
[...]
> I've configured succesfuly different QoS configurations, but there is
> one that *allways* returns a segmentation fault in the kernel module (or
> code). This part of the kernel seems to crash when installing an IP
> filter. I've tried the code in 2 different computers with different
> hardware and even different kernel version (2.4.25 and 2.6.4)

Do you still notice the same behavior if you do not load any vmware nor
nvidia thing ?

--
Ueimor
