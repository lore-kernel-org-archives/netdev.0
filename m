From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] LLC SOCK_DGRAM enhancements
Date: Thu, 25 May 2006 15:11:45 -0700 (PDT)
Message-ID: <20060525.151145.38321217.davem@davemloft.net>
References: <20060524000414.052569000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29084
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030467AbWEYWLk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 18:11:40 -0400
To: shemminger@osdl.org
In-Reply-To: <20060524000414.052569000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 23 May 2006 17:04:14 -0700

> I want to use AF_LLC and SOCK_DGRAM for handling Spanning
> Tree Protocol packets in user space. The existing code doesn't work
> and also doesn't support multicast. These basic problems and
> add some cleanups.

All applied, thanks Stephen.
