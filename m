From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: wrong arp query with policy routing
Date: Thu, 20 Sep 2007 11:52:33 -0400
Message-ID: <46F29741.2030505@redhat.com>
References: <BAY103-DAV2BC129A14C4A29986CC0CB2B80@phx.gbl> <BAY103-DAV12BF0DF9E47B1577FB9814B2B90@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35676 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756210AbXITPwh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 11:52:37 -0400
In-Reply-To: <BAY103-DAV12BF0DF9E47B1577FB9814B2B90@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Is there a way to force linux to make an arp
> probe with the source ip belonging to the
> same subnet requesting ip?

Umm, arp_filter?
