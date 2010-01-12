From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
 (v3)
Date: Mon, 11 Jan 2010 22:24:00 -0800 (PST)
Message-ID: <20100111.222400.253153531.davem@davemloft.net>
References: <20100110235017.GA8959@electric-eye.fr.zoreil.com>
	<20100110.224504.247142858.davem@davemloft.net>
	<20100112001646.GA7017@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41733
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750741Ab0ALGXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 01:23:51 -0500
In-Reply-To: <20100112001646.GA7017@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 12 Jan 2010 01:16:46 +0100

> I have spent the evening disrupting the communication. As a challenger
> one does not even need complete control : send a few random packets and
> the card goes to neverland. :o/
> 
> I'll do some tests limiting the crap at the first packet.

Thanks for doing this work Francois.
