From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hdlc: fix compile problem
Date: Wed, 07 Jan 2009 18:13:02 -0800 (PST)
Message-ID: <20090107.181302.268381875.davem@davemloft.net>
References: <m3tz8atxwv.fsf@maximus.localdomain>
	<20090107170842.6ee4eb77@extreme>
	<m3priytwoo.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37477
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751034AbZAHCNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 21:13:01 -0500
In-Reply-To: <m3priytwoo.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Thu, 08 Jan 2009 02:26:31 +0100

> "dev->netdev_ops->start_hard_xmit != hdlc_xmit" is a dirty hack.
> IFF_WAN_HDLC is much cleaner though it's an additional bit consumed.
> Sure, I like it.

Ok, Stephen please formally resubmit this final version with
full commit message etc..

Thanks.
