From: Ron Madrid <ron_madrid@sbcglobal.net>
Subject: Re: [PATCH] Marvell 88E1118 interrupt fix
Date: Mon, 26 Jan 2009 12:34:47 -0800 (PST)
Message-ID: <634733.68526.qm@web83501.mail.sp1.yahoo.com>
References: <20090126.122132.106851564.davem@davemloft.net>
Reply-To: ron_madrid@sbcglobal.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web83501.mail.sp1.yahoo.com ([216.252.120.157]:22483 "HELO
	web83501.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755315AbZAZUl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 15:41:28 -0500
In-Reply-To: <20090126.122132.106851564.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm sorry.  I sent this to the wrong mail list.  My apologies.

Ron


--- On Mon, 1/26/09, David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Subject: Re: [PATCH] Marvell 88E1118 interrupt fix
> To: ron_madrid@sbcglobal.net
> Cc: netdev@vger.kernel.org
> Date: Monday, January 26, 2009, 12:21 PM
> From: Ron Madrid <ron_madrid@sbcglobal.net>
> Date: Fri, 23 Jan 2009 12:04:10 -0800
> 
> > This patch adjusts the LED control so that interrupt
> lines are not reading LEDs
> > and effectively causing indefinite interrupts to the
> controller.
> > 
> > Signed-off-by: Ron Madrid
> <ron_madrid@sbcglobal.net>
> 
> There is no drivers/net/tsec.c in the tree.  I can't
> even find
> 'phy_info_M88E1118' in any source file.
> 
> What are you generating this patch against?
