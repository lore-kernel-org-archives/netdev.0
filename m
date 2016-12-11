From: David Miller <davem@davemloft.net>
Subject: Re: Remove private tx queue locks
Date: Sat, 10 Dec 2016 23:27:23 -0500 (EST)
Message-ID: <20161210.232723.1867472079856079383.davem@davemloft.net>
References: <1481241343-18062-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        romieu@fr.zoreil.com, pavel@ucw.cz, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481241343-18062-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Fri,  9 Dec 2016 00:55:41 +0100

> this patch series removes unnecessary private locks in the sxgbe and the
> stmmac driver.
> 
> v2:
> - adjust commit message

Series applied to net-next, thanks.
