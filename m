From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: add fix_mac_speed support for socfpga
Date: Fri, 22 Aug 2014 12:35:51 -0700 (PDT)
Message-ID: <20140822.123551.2188211356695902205.davem@davemloft.net>
References: <1408516413-2928-1-git-send-email-lftan@altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lftan.linux@gmail.com, peppe.cavallaro@st.com, vbridger@altera.com
To: lftan@altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408516413-2928-1-git-send-email-lftan@altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ley Foon Tan <lftan@altera.com>
Date: Wed, 20 Aug 2014 14:33:33 +0800

> This patch adds fix_mac_speed() support for
> Altera socfpga Ethernet controller. Emac splitter is a
> soft IP core in FPGA system that converts GMII interface from
> Synopsys mac to RGMII/SGMII interface. This splitter core is
> an optional IP if user would like to use RGMII/SGMII
> interface in their system. Software needs to update a register
> in splitter core when there is speed change.
> 
> Signed-off-by: Ley Foon Tan <lftan@altera.com>

Applied.
