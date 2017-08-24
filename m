From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: stmmac: socfgpa: Ensure emac bit set in sys
 manager for MII/GMII/SGMII.
Date: Wed, 23 Aug 2017 20:27:24 -0700 (PDT)
Message-ID: <20170823.202724.2186020480426006312.davem@davemloft.net>
References: <1503404707-25662-1-git-send-email-stephan.gatzka@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: stephan.gatzka@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503404707-25662-1-git-send-email-stephan.gatzka@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephan Gatzka <stephan.gatzka@gmail.com>
Date: Tue, 22 Aug 2017 14:25:07 +0200

> When using MII/GMII/SGMII in the Altera SoC, the phy needs to be
> wired through the FPGA. To ensure correct behavior, the appropriate
> bit in the System Manager FPGA Interface Group register needs to be
> set.
> 
> Signed-off-by: Stephan Gatzka <stephan.gatzka@gmail.com>

Applied, thanks.
