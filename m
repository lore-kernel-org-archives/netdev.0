From: David Miller <davem@davemloft.net>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Thu, 10 Aug 2006 23:45:38 -0700 (PDT)
Message-ID: <20060810.234538.00788063.davem@davemloft.net>
References: <20060802.135859.91441473.davem@davemloft.net>
	<Pine.LNX.4.64.0608031101220.14955@bizon.gios.gov.pl>
	<Pine.LNX.4.64.0608102013020.9012@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Christophe.Devriese@eurid.eu, fubar@us.ibm.com,
	k-iwami@cj.jp.nec.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56036
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932313AbWHKGp3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 02:45:29 -0400
To: olel@ans.pl
In-Reply-To: <Pine.LNX.4.64.0608102013020.9012@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Oledzki <olel@ans.pl>
Date: Thu, 10 Aug 2006 20:18:23 +0200 (CEST)

> OK, this patch really solves the bug from my report. Are there any chances 
> for similar fix in the net-2.6.19.git?

I'm still thinking about this patch and what various people have
explained about the situation.
