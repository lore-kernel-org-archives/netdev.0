From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/2] af_mpls: fix undefined reference to
 ip6_route_output with CONFIG_IPV6=n
Date: Thu, 30 Jul 2015 14:02:52 -0700 (PDT)
Message-ID: <20150730.140252.110937713726990587.davem@davemloft.net>
References: <55BA252F.3070601@cumulusnetworks.com>
	<1438268245.17421.5.camel@stressinduktion.org>
	<55BA8B36.9030402@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, tgraf@suug.ch, rshearma@brocade.com,
	stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	jon.maloy@ericsson.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbbG3VCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 17:02:53 -0400
In-Reply-To: <55BA8B36.9030402@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>
Date: Thu, 30 Jul 2015 13:38:14 -0700

> but was only concerned about ipv6 module unload.

It is not possible to unload the ipv6 module.
