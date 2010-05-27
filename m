From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Thu, 27 May 2010 09:46:45 +0200
Message-ID: <20100527074645.GC2728@nuttenaction>
References: <20100526231512.GD2684@nuttenaction>
 <20100526.200443.232751390.davem@davemloft.net>
 <20100527070827.GB2728@nuttenaction>
 <20100527.002851.02281005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:37990 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750852Ab0E0Hqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 03:46:46 -0400
Content-Disposition: inline
In-Reply-To: <20100527.002851.02281005.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller | 2010-05-27 00:28:51 [-0700]:

>Superior or not, it's simply never going to happen.  We are far beyond
>being able to get to where we were before NAT'ing and shaping devices
>started to get inserted everywhere on the network.
>
>And I also don't see any of this stuff as fundamentally proprietary.

We will see! If no real interaction between peers is required
ISP/Carrier/InternetExchanges will start to put their proprietary components
into the network. Because they have niffty features, the product developed
phase is shorten (no borring standardizations necessary) and so on. This is no
new insight.

>People want deep packet inspection, people want to control their user's
>traffic.  And people, most importantly, are willing to pay for this.
>
>Therefore, these elements will always be in the network.
>
>Better to co-exist with them and use them to our advantage instead of
>fantasizing about a utopia where they don't exist.

Sure, we have no alternative.

HGN


-- 
Hagen Paul Pfeifer <hagen@jauu.net>  ||  http://jauu.net/
Telephone: +49 174 5455209           ||  Key Id: 0x98350C22
Key Fingerprint: 490F 557B 6C48 6D7E 5706 2EA2 4A22 8D45 9835 0C22
