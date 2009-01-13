From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] asix: Add support for AX88772A devices
Date: Mon, 12 Jan 2009 17:12:49 -0800 (PST)
Message-ID: <20090112.171249.245244737.davem@davemloft.net>
References: <20090111.001704.107600670.davem@davemloft.net>
	<20090112.161850.235337113.davem@davemloft.net>
	<1231808775.591.6.camel@dhollis-lnx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: dhollis@davehollis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56876
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756343AbZAMBMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 20:12:48 -0500
In-Reply-To: <1231808775.591.6.camel@dhollis-lnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Hollis <dhollis@davehollis.com>
Date: Mon, 12 Jan 2009 20:06:15 -0500

> I'm currently waiting on feedback from the original contributor of the
> patch.  I looked through the mii_ethtool_gset function and it
> effectively is performing the same task (and then some) so I can't see
> any reason why the link_reset() function needs the changes.  I'll submit
> a new patch without those changes and will submit any changes to the
> link_reset() that may happen to be required when I get a response from
> the contributor.

Thanks a lot David.
