From: David Miller <davem@davemloft.net>
Subject: Re: [DECNET]: Add support for fwmark masks in routing rules
Date: Fri, 25 Aug 2006 16:11:22 -0700 (PDT)
Message-ID: <20060825.161122.34762393.davem@davemloft.net>
References: <44EEE994.90404@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40324
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964795AbWHYXLS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:11:18 -0400
To: kaber@trash.net
In-Reply-To: <44EEE994.90404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 25 Aug 2006 14:14:12 +0200

> [DECNET]: Add support for fwmark masks in routing rules
> 
> Add support for fwmark masks. For compatibility a mask of 0xFFFFFFFF is used
> when a mark value != 0 is sent without a mask.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
