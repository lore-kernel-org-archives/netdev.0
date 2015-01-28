From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] bonding: various 802.3ad fixes
Date: Tue, 27 Jan 2015 17:09:27 -0800 (PST)
Message-ID: <20150127.170927.1945702034995194886.davem@davemloft.net>
References: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: jtoppins@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514AbbA1BJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 20:09:30 -0500
In-Reply-To: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Date: Mon, 26 Jan 2015 01:16:56 -0500

> This patch series is a forward porting of patches we (Cumulus) are shipping
> in our 3.2 series kernels. These fixes attempt to make 802.3ad bonding mode
> more predictable in certian state machine transtions in addition to fixing
> 802.3ad bond carrier determination when bonding min_links option is changed.
> Specific notes are contained within each patch.
> 
> For this patch series there are no userspace facing changes, a diff between
> the modinfo output showed no difference. However, there are behavioral
> facing changes, primarily in the bond carrier state. Please make sure to
> review carefully.
> 
> v2:
>  * fixed some style issues
>  * dropped a portion of patch 1 in favor of more testing on my side

Series applied, thanks.
