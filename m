From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: fix incorrect bit set in gmac4 mdio addr
 register
Date: Tue, 27 Dec 2016 12:30:17 -0500 (EST)
Message-ID: <20161227.123017.563763237782232696.davem@davemloft.net>
References: <1482869261-23803-1-git-send-email-hock.leong.kweh@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joao.Pinto@synopsys.com, peppe.cavallaro@st.com,
        seraphin.bonnaffe@st.com, f.fainelli@gmail.com,
        alexandre.torgue@gmail.com, manabian@gmail.com,
        niklas.cassel@axis.com, johan@kernel.org, pavel@ucw.cz,
        boon.leong.ong@intel.com, weifeng.voon@intel.com,
        lars.persson@axis.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: hock.leong.kweh@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482869261-23803-1-git-send-email-hock.leong.kweh@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kweh, Hock Leong"	<hock.leong.kweh@intel.com>
Date: Wed, 28 Dec 2016 04:07:41 +0800

> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
> 
> Fixing the gmac4 mdio write access to use MII_GMAC4_WRITE only instead of
> OR together with MII_WRITE.
> 
> Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>

Applied.
