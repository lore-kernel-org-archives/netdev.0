From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: fix double-initialization of phy_iface
Date: Thu, 05 Nov 2015 14:09:52 -0500 (EST)
Message-ID: <20151105.140952.818101884968541238.davem@davemloft.net>
References: <1446715606-10326-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446715606-10326-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Date: Thu,  5 Nov 2015 10:26:46 +0100

> The variable phy_iface is double-initialized to itself.
> This patch remove that.
> 
> Reported-by: coverity (CID 1271141)
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>

Applied.
