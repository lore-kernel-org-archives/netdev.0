From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2] net/macvtap: fix reference counting
Date: Thu, 18 Feb 2010 16:44:29 +0100
Message-ID: <201002181644.29740.arnd@arndb.de>
References: <201002111645.02770.arnd@arndb.de> <1265922577.28768.6.camel@w-sridhar.beaverton.ibm.com> <20100215.215341.66627877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, kaber@trash.net, eswierk@aristanetworks.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:55789 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755932Ab0BRPom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 10:44:42 -0500
In-Reply-To: <20100215.215341.66627877.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 16 February 2010, David Miller wrote:
> From: Sridhar Samudrala <sri@us.ibm.com>
> > Acked-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> Applied.

Thanks for applying this one, but unfortunately I had reworked
the patch in a different way in the meantime and Sridhar has
added another patch conflicting with my rework. I think I've
got it all sorted out now, so I'll send a new series with
the three patches I was intending to get merged, but rebased
on this one and mostly reverting it.

Sridhar, please have a look at this series and send an Ack
if you're fine with it.

	Arnd
