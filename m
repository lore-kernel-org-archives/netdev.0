From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] NET: tg3: fix brace, switch, and comma spacing coding
 style in tg3.c This is a patch to the tg3.c file that aligns switch and
 case statements, else statements following braces, and inserts a space
 after commas listed in the coding style g
Date: Sat, 13 Mar 2010 12:22:22 -0800
Message-ID: <1268511742.30289.74.camel@Joe-Laptop.home>
References: <b6bf7b051003131152t38c8b1e1m33e8844468b9e46a@mail.gmail.com>
	 <20100313.115555.209991546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: thisdyingdream@gmail.com, sjharms@gmail.com, mcarlson@broadcom.com,
	mchan@broadcom.com, benli@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sharms@ubuntu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1691 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933030Ab0CMUWY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Mar 2010 15:22:24 -0500
In-Reply-To: <20100313.115555.209991546.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-03-13 at 11:55 -0800, David Miller wrote:
> From: Steven Harms <thisdyingdream@gmail.com>
> Date: Sat, 13 Mar 2010 14:52:26 -0500
> 
> > Would you like me to submit the patch adding only the spaces after
> > commas and leave the rest of the defines as is, or discard the changes
> > all together?
> 
> I would like you to toss them altogether.

I think that Steven got off on the wrong foot
a bit by adding the parentheses to the defines.

I think the other changes he suggested are
tree-wide style consistency only and are ok.

Perhaps you might reconsider later, after
net-next reopens.


