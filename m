From: David Miller <davem@davemloft.net>
Subject: Re: [v4 net-next PATCH 0/3] Energy Efficient Ethernet (eee) support
Date: Thu, 07 Jun 2012 13:19:33 -0700 (PDT)
Message-ID: <20120607.131933.2241895081676978993.davem@davemloft.net>
References: <1339038788-3447-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com,
	peppe.cavallaro@st.com, bhutchings@solarflare.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755176Ab2FGUTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 16:19:34 -0400
In-Reply-To: <1339038788-3447-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Thu, 7 Jun 2012 06:13:05 +0300

> This patch series adds energy efficient ethernet support for the
> bnx2x driver (for new chips with appropriate phys). 
> It also extends the ethtool API to enable control of the eee feature.
> 
> Another patch series has been sent to Ben to allow the ethtool application
> to use this new API.

All applied to net-next, thanks.
