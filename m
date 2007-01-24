From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6] RAW: Add checksum default defines for MH.
Date: Tue, 23 Jan 2007 22:19:18 -0800 (PST)
Message-ID: <20070123.221918.35467190.davem@davemloft.net>
References: <11678167423123-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, takamiya@po.ntts.co.jp,
	netdev@vger.kernel.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47865
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030248AbXAXGTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:19:19 -0500
In-Reply-To: <11678167423123-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Wed,  3 Jan 2007 18:32:22 +0900

> Add checksum default defines for mobility header(MH) which
> goes through raw socket. As the result kernel's behavior is
> to handle MH checksum as default.
> 
> This patch also removes verifying inbound MH checksum at
> mip6_mh_filter() since it did not consider user specified
> checksum offset and was redundant check with raw socket code.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Did a complete agreement occur that this patch is ok?

Thank you.
