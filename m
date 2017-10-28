From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] stmmac: copy unicast mac address to MAC
 registers
Date: Sat, 28 Oct 2017 19:04:57 +0900 (KST)
Message-ID: <20171028.190457.1686842747601283837.davem@redhat.com>
References: <1509072722-31657-1-git-send-email-vbhadram@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
To: vbhadram@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38076 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751121AbdJ1KFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 06:05:09 -0400
In-Reply-To: <1509072722-31657-1-git-send-email-vbhadram@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bhadram Varka <vbhadram@nvidia.com>
Date: Fri, 27 Oct 2017 08:22:02 +0530

> Currently stmmac driver not copying the valid ethernet
> MAC address to MAC registers. This patch takes care
> of updating the MAC register with MAC address.
> 
> Signed-off-by: Bhadram Varka <vbhadram@nvidia.com>

Applied, thank you.
