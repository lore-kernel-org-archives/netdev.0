From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] stmmac: add header inclusion protection
Date: Fri, 24 Aug 2012 13:25:20 -0400 (EDT)
Message-ID: <20120824.132520.988802945468353296.davem@davemloft.net>
References: <1345706898-13007-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rayagond@vayavyalabs.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54531 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758807Ab2HXRZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 13:25:23 -0400
In-Reply-To: <1345706898-13007-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 23 Aug 2012 09:28:18 +0200

> From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
> 
> This patch adds "#ifndef __<header>_H" for protecting header from double
> inclusion.
> 
> Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
> Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thanks.
