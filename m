From: David Miller <davem@davemloft.net>
Subject: Re: Section conflict compile failures in net
Date: Tue, 31 May 2011 19:24:32 -0700 (PDT)
Message-ID: <20110531.192432.480538486.davem@davemloft.net>
References: <1306445993.4048.58.camel@mulgrave.site>
	<20110531.154531.493226762.davem@davemloft.net>
	<20110601012739.GA25705@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James.Bottomley@HansenPartnership.com, netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758615Ab1FACZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 22:25:39 -0400
In-Reply-To: <20110601012739.GA25705@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Wed, 1 Jun 2011 03:27:40 +0200

> __devinitconst ID tables do work for PCI drivers. What's different fo=
r EISA,
> and why is it working in x86 allyesconfig build but not in hppa?

James shows that it doesn't work for PCI drivers either.
