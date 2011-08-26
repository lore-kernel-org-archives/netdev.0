From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/phy: fix DP83865 phy interrupt handler
Date: Fri, 26 Aug 2011 12:50:50 -0400 (EDT)
Message-ID: <20110826.125050.2162441992717183883.davem@davemloft.net>
References: <1314083234-20361-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tshu@msc-ge.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985Ab1HZQu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:50:59 -0400
In-Reply-To: <1314083234-20361-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 23 Aug 2011 09:07:14 +0200

> According to the DP83865 datasheet we need to clear
> the interrupt status bit by writing a 1 to the
> corresponding bit in INT_CLEAR (2:0 are reserved).
> 
> Proposed and tested by Thorsten.
> 
> Signed-off-by: Thorsten Schubert <tshu@msc-ge.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
