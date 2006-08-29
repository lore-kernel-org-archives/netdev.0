From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: RFC3465 Appropriate Byte Count fix
Date: Tue, 29 Aug 2006 02:02:12 -0700 (PDT)
Message-ID: <20060829.020212.106266049.davem@davemloft.net>
References: <0J4D00BIVXNW7H40@NTTDoCoMo.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35502
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750844AbWH2JCa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 05:02:30 -0400
To: osugad@s1.nttdocomo.co.jp
In-Reply-To: <0J4D00BIVXNW7H40@NTTDoCoMo.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daikichi Osuga <osugad@s1.nttdocomo.co.jp>
Date: Tue, 22 Aug 2006 14:52:43 +0900

> From: Daikichi Osuga <osugad@s1.nttdocomo.co.jp>
> 
> RFC3465 Appropriate Byte Count fix
> slow start after retransmit timeout does not work is fixed.
> case of L=2*SMSS acked bytes comparison is fixed.
> 
> Signed-off-by: Daikichi Osuga <osugad@s1.nttdocomo.co.jp>

Thank you very much for these bug fixes.

Patch applied.
