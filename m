From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH] 2.6.22.6 netfilter: sk_setup_caps in ip_make_route_harder
Date: Fri, 21 Sep 2007 14:39:58 +0200
Message-ID: <46F3BB9E.4000105@trash.net>
References: <20070919093648.GA7491@router.lepton.home> <46F13999.30700@trash.net> <46F13D7D.6010603@trash.net> <20070919155554.GA11710@router.lepton.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: lepton <ytht.net@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63533 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752907AbXIUMrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 08:47:46 -0400
In-Reply-To: <20070919155554.GA11710@router.lepton.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

lepton wrote:
> Yes, you are right.
> What do you think about this:
> For all packets can be sent out, we just disable 
> all things in sk_route_caps in ip_route_me_harder


Whats the point of doing that? Is rerouting breaking anything for you?
