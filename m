From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4 (net.git)] stmmac update Feb_2012
Date: Tue, 14 Feb 2012 14:16:20 -0500 (EST)
Message-ID: <20120214.141620.1418537030681644675.davem@davemloft.net>
References: <1329203508-19612-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757072Ab2BNTQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 14:16:30 -0500
In-Reply-To: <1329203508-19612-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 14 Feb 2012 08:11:44 +0100

> This updates the stmmac adding some patches already reviewed in this
> mailing list by D. Miller.  I've rebased these patches against this
> recent patch: [PATCH] [trivial] stmicro: Fix typo in stmmac_pci.c
> and stmmac_platform.c applied by Maintainer (to avoid conflicts in
> the plt and pci files).

You're telling me in the subject line you want these patches applied
to net.git but they don't actually apply cleanly to that tree.

I can't tell you how insanely irritating this kind of thing is, it's
where most of my time gets wasted.
