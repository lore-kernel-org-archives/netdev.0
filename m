From: Amit Kucheria <amitk@ittc.ku.edu>
Subject: Re: kernel module to generate UDP & TCP traffic?
Date: Mon, 15 Apr 2002 18:43:09 -0500 (CDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0204151840060.10022-100000@havoc.ittc.ku.edu>
References: <3CBB6414.5040506@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3CBB6414.5040506@candelatech.com>
List-Id: netdev.vger.kernel.org

On Mon, 15 Apr 2002, Ben Greear wrote:

> I'm considering writing a kernel module that will be used to
> generate and receive copious amounts of Ethernet, UDP, and TCP
> traffic.  I would prefer to tweak/use an existing tool if any
> is available.  Any suggestions?
> 
> Thanks,
> Ben


How about using the tun/tap devices in the 2.4. kernels which can RX/TX 
Ethernet frames from/to userspace?

http://vtun.sourceforge.net

-- 
I'm an angel!!! Honest!
The horns are just there to hold the halo up straight.
^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^
                  Amit Kucheria
          EECS Grad. Research Assistant
         University of Kansas @ Lawrence
   (R)+1-(785)-830 8521 ||| (O)+1-(785)-864 7774
____________________________________________________

