From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: wireless (was Re: 2.6.18 -mm merge plans)
Date: Mon, 05 Jun 2006 11:26:55 +0100
Message-ID: <1149503215.30554.6.camel@localhost.localdomain>
References: <20060604135011.decdc7c9.akpm@osdl.org>
	 <20060605010636.GB17361@havoc.gtf.org>
	 <20060604181515.8faa8fcf.akpm@osdl.org>
	 <20060605083321.GA15690@rhlx01.fht-esslingen.de>
	 <1149497109.3111.28.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andreas Mohr <andi@rhlx01.fht-esslingen.de>,
	Andrew Morton <akpm@osdl.org>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com, Denis Vlasenko <vda@ilport.com.ua>,
	acx100-devel@lists.sourceforge.net,
	acx100-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:60387 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1750866AbWFEKNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 06:13:20 -0400
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1149497109.3111.28.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Llu, 2006-06-05 am 10:45 +0200, ysgrifennodd Arjan van de Ven:
>  It's just that a cleanroom approach is a sure way to prove
> you didn't copy. That's all.

Which is an extremely important detail especially if you have been
reverse engineering another driver for the same or similar OS where it
is likely that people will retain knowledge and copy rather than
re-implement things.

We've had "fun" with this before and the pwc camera driver. I don't want
to see a repeat of that.

Alan

