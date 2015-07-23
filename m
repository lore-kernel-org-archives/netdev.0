From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_mpls: fix undefined reference to
 ip6_route_output
Date: Thu, 23 Jul 2015 00:09:49 -0700 (PDT)
Message-ID: <20150723.000949.1617391267827343249.davem@davemloft.net>
References: <20150722.130444.1245167673786115378.davem@davemloft.net>
	<20150722201729.GB26717@pox.localdomain>
	<55AFFF47.8040704@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbbGWG46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 02:56:58 -0400
In-Reply-To: <55AFFF47.8040704@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>
Date: Wed, 22 Jul 2015 13:38:31 -0700

> I cant think of a way to fix the current problem with my patch...

I guess it's not obvious that adding CONFIG_MPLS_IPV6 would solve
the problem perfectly.
