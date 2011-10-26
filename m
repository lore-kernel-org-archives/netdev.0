From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] stmmac: fix NULL pointer dereference in
 capabilities fixup
Date: Wed, 26 Oct 2011 18:34:20 -0400 (EDT)
Message-ID: <20111026.183420.270100530207344332.davem@davemloft.net>
References: <1319637339-14866-1-git-send-email-peppe.cavallaro@st.com>
	<1319637339-14866-2-git-send-email-peppe.cavallaro@st.com>
	<20111026.172330.67657472938640633.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, keguang.zhang@gmail.com, angus.clark@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32901 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181Ab1JZWe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 18:34:28 -0400
In-Reply-To: <20111026.172330.67657472938640633.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 26 Oct 2011 17:23:30 -0400 (EDT)

> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Wed, 26 Oct 2011 15:55:38 +0200
> 
>> From: Angus Clark <angus.clark@st.com>
>> 
>> Signed-off-by: Angus Clark <angus.clark@st.com>
>> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> 
> Applied.

I've reverted these three patches, please resubmit after you've
addressed Ben Hutchings concerns about priv->phydev

Thanks.
