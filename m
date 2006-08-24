From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 37/44] [IPV6] MIP6: Report to user-space when home
 address option is rejected.
Date: Wed, 23 Aug 2006 20:46:52 -0700 (PDT)
Message-ID: <20060823.204652.39663208.davem@davemloft.net>
References: <11563453673786-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453672531-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453674194-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26778
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030265AbWHXDqu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:46:50 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453674194-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:38 +0900

> Report to user-space when home address option is rejected.
> In receiving this message user-space application will send Mobile IPv6 binding
> error. It is rate-limited by kernel.
> Based on MIPL2 kernel patch.
> 
> This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks.
