From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4]: Add support for fwmark masks in routing rules
Date: Fri, 25 Aug 2006 16:10:24 -0700 (PDT)
Message-ID: <20060825.161024.56812059.davem@davemloft.net>
References: <44EEE98D.9040100@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:39556
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422869AbWHYXKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:10:19 -0400
To: kaber@trash.net
In-Reply-To: <44EEE98D.9040100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 25 Aug 2006 14:14:05 +0200

> [IPV4]: Add support for fwmark masks in routing rules
> 
> Add a FRA_FWMASK attributes for fwmark masks. For compatibility a mask of
> 0xFFFFFFFF is used when a mark value != 0 is sent without a mask.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
