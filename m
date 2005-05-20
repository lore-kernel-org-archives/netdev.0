From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 17:18:29 -0400
Message-ID: <428E5425.3090605@pobox.com>
References: <1116609329.31523.16.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, ffan@broadcom.com,
        lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1116609329.31523.16.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> A new driver bnx2 for Broadcom bcm5706 is available. Since the patch is
> over 500K, I've put it on the ftp server:
> 
> ftp://Net_sys_anon@ftp1.broadcom.com/bnx2-2.patch
> 
> The patch also includes new 1000BASE-X advertisement bit definitions in
> mii.h
> 
> Thanks to David Miller and Jeff Garzik for reviewing and their valuable
> feedback.

For what it's worth, DaveM and I decided that the patch submission 
procedure will be the same for bnx2 and tg3:  DaveM will merge the bnx2 
driver and patches, and send them upstream.

(this deviates from the normal procedure of me merging all net driver 
changes)

	Jeff
