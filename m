From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ircomm - set owner get rid of MOD_INC/MOD_DEC
Date: Mon, 18 Aug 2003 18:07:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F414E3F.9090908@pobox.com>
References: <20030818111746.34b9e52b.shemminger@osdl.org> <20030818184059.GA6457@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20030818184059.GA6457@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> On Mon, Aug 18, 2003 at 11:17:46AM -0700, Stephen Hemminger wrote:
> 
>>Ircomm in 2.6.0-test3 can just set the owner field in the tty structure
>>like other drivers, and not mess with MOD_INC/MOD_DEC.
> 
> 
> 	You missed a couple of comments. I sent the more complete
> version of the exact same patch a few weeks ago to Jeff Garzik, you
> may want to check with Jeff what the status on this.
> 	Of course, I would prefer the "more complete" version to go
> in.
> 
> 	By the way, because of Jeff's turnaround, we are going to have
> this problem a lot. All my pending IrDA patches are listed on my web
> page, you may want to check it :


Yes, I have "ircomm module fix" and "NSC '39x fixes" queued, and going 
to Linus today with some more net driver stuff.

	Jeff
