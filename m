From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 33/44] [IPV6] MIP6: Add sending mobility header
 functions through raw socket.
Date: Wed, 23 Aug 2006 20:37:03 -0700 (PDT)
Message-ID: <20060823.203703.102615118.davem@davemloft.net>
References: <11563453671944-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453671187-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453672959-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40901
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030239AbWHXDhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:37:01 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453672959-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:34 +0900

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> Mobility header is built by user-space and sent through raw socket.
> Kernel just extracts its type to flow.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks a lot.
