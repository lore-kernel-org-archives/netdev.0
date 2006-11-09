From: David Miller <davem@davemloft.net>
Subject: Re: [patch 9/9] net: uninline xfrm_selector_match()
Date: Wed, 08 Nov 2006 22:46:38 -0800 (PST)
Message-ID: <20061108.224638.112982624.davem@davemloft.net>
References: <200611090351.kA93pBEl003702@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@mandriva.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9872
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161816AbWKIGqc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 01:46:32 -0500
To: akpm@osdl.org
In-Reply-To: <200611090351.kA93pBEl003702@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Wed, 08 Nov 2006 19:51:10 -0800

> From: Andrew Morton <akpm@osdl.org>
> 
> Six callsites, huge.
> 
> Cc: Arnaldo Carvalho de Melo <acme@mandriva.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks Andrew.
