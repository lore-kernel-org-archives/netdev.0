From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: stmmac: replace hardcoded function name by
 __func__
Date: Thu, 17 Nov 2016 13:31:06 -0500 (EST)
Message-ID: <20161117.133106.1322675426903118615.davem@davemloft.net>
References: <1479323381-26639-1-git-send-email-clabbe.montjoie@gmail.com>
        <1479323381-26639-2-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479323381-26639-2-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Wed, 16 Nov 2016 20:09:40 +0100

> From: LABBE Corentin <clabbe.montjoie@gmail.com>
> 
> Some printing have the function name hardcoded.
> It is better to use __func__ instead.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Applied to net-next.
