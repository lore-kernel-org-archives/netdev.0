From: David Miller <davem@davemloft.net>
Subject: Re: stmmac: improve logging
Date: Tue, 15 Sep 2015 13:31:02 -0700 (PDT)
Message-ID: <20150915.133102.2223944615412621607.davem@davemloft.net>
References: <1441888653-30535-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, joe@perches.com
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441888653-30535-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Date: Thu, 10 Sep 2015 14:37:28 +0200

> This patch series try to improve logging of the stmmac driver.
> 
> Changes since v1
> - Use netdev_xxx instead of dev_xxx
> - Use netif_xxx instead of "if (netif_msg_type) dev_xxx"

This series does not apply cleanly to the current tree, please
respin.

Thanks.
