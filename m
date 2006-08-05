From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Replace CHECKSUM_HW by
 CHECKSUM_PARTIAL/CHECKSUM_COMPLETE
Date: Sat, 05 Aug 2006 00:59:12 -0700 (PDT)
Message-ID: <20060805.005912.28419808.davem@davemloft.net>
References: <44D447E3.3010108@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47544
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422756AbWHEH7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 03:59:04 -0400
To: kaber@trash.net
In-Reply-To: <44D447E3.3010108@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 05 Aug 2006 09:25:23 +0200

> This is the latest version of the checksum patches. Retested everything,
> I think they're ready to go in. On top of net-2.6.19 from a few minutes
> ago.

All 3 patches applied, thanks a lot for doing this work Patrick.
