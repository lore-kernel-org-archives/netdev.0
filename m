From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.6.0-rc3 1/2] of/mdio: Add dummy functions in
 of_mdio.h.
Date: Thu, 30 Aug 2012 12:38:29 -0400 (EDT)
Message-ID: <20120830.123829.822912034653430266.davem@davemloft.net>
References: <1345809539-27684-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, laurentp@cse-semaphore.com,
	devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544Ab2H3Qic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 12:38:32 -0400
In-Reply-To: <1345809539-27684-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Fri, 24 Aug 2012 12:58:59 +0100

> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> This patch adds dummy functions in of_mdio.h, so that driver need not
> ifdef there code with CONFIG_OF.
> 
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Applied to net-next.
