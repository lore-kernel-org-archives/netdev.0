From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix endianness on tipc subscriber messages
Date: Mon, 08 Mar 2010 12:54:29 -0800 (PST)
Message-ID: <20100308.125429.14323494.davem@davemloft.net>
References: <20100308200315.GE23634@hmsreliant.think-freely.org>
	<29C1DC0826876849BDD9F1C67ABA29430728D116@ala-mail09.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51183
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752323Ab0CHUyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 15:54:10 -0500
In-Reply-To: <29C1DC0826876849BDD9F1C67ABA29430728D116@ala-mail09.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Stephens, Allan" <allan.stephens@windriver.com>
Date: Mon, 8 Mar 2010 12:48:38 -0800

> Secondly, I would have expected this patch to be applied to
> net-next-2.6, since the functionality being changed here (at least
> the first part of it) is more like a feature enhancement than a bug
> fix.

It fixes a bug so I'm going to apply it.

You can't disappear from maintaining this shinking ship for years then
complain about people who are actually working to get upstream back
into shape.
