From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Question about potential problem in net/ipv4/route.c
Date: Thu, 12 Oct 2006 00:48:08 -0700 (PDT)
Message-ID: <20061012.004808.108740137.davem@davemloft.net>
References: <452DD724.4030502@cosmosbay.com>
	<20061011.230233.122062793.davem@davemloft.net>
	<452DE243.7050903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52959
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422805AbWJLHsK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 03:48:10 -0400
To: dada1@cosmosbay.com
In-Reply-To: <452DE243.7050903@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 12 Oct 2006 08:35:47 +0200

> How about avoiding the fwmark thing if !CONFIG_IP_ROUTE_FWMARK

I've added that, good idea.
