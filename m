From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: [PATCH 2/4] irda check error on memcpy_fromiovec (resend)
Date: Fri, 16 Jan 2004 17:40:05 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040117014005.GA14291@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, Chris Wright <chrisw@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chris Wright wrote :
> Check the return value on memcpy_fromiovec().
> 
>  net/irda/af_irda.c |   18 +++++++++++++++---
>  1 files changed, 15 insertions(+), 3 deletions(-)

	Oups, I must have missed the first edition. I've added this is
my patch queue in case Dave doesn't pick it up, but as you can see I
now have a bit of backlog :
	http://www.hpl.hp.com/personal/Jean_Tourrilhes/IrDA/IrDA.html

	Have fun...

	Jean
