From: David Schweikert <david@schweikert.ch>
Subject: Re: niu: ethtool -s support?
Date: Wed, 26 Nov 2008 10:50:21 +0100
Message-ID: <20081126095021.GB20045@schweikert.ch>
References: <20081125133530.GA1633@schweikert.ch> <20081125.133124.74121407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nigel.schweikert.ch ([88.198.52.145]:58440 "EHLO
	mail.schweikert.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbYKZJu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 04:50:26 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.schweikert.ch (Postfix) with ESMTP id A8F0B12DAEC
	for <netdev@vger.kernel.org>; Wed, 26 Nov 2008 10:50:24 +0100 (CET)
Received: from mail.schweikert.ch ([127.0.0.1])
	by localhost (mail.schweikert.ch [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BInCUCpHKHAK for <netdev@vger.kernel.org>;
	Wed, 26 Nov 2008 10:50:22 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20081125.133124.74121407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2008 at 13:31:24 -0800, David Miller wrote:
> > It is apparently not possible to set the link parameters on a niu
> > interface (speed, duplex mode, auto-negotiation) with ethtool.
> > Is support for it planned?
> 
> Yes, at some point, although that work is pretty low priority
> to be honest.

OK, thanks for the information. Would it be possible for the company I
work for, to somehow sponsor the development of this feature? Do you
know maybe a fellow developer that might be interested?

This feature is the prerequisite for us to be able to use the Sun 8x
Express Quad Gigabit Ethernet card.

Cheers
David
