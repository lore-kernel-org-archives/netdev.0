From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 (net.git) 0/3] stmmac: fix PTP support
Date: Tue, 15 Nov 2016 19:56:32 -0500 (EST)
Message-ID: <20161115.195632.900312673444073979.davem@davemloft.net>
References: <1479112050-14042-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com,
        rayagond@vayavyalabs.com, richardcochran@gmail.com,
        linux-kernel@vger.kernel.org, seraphin.bonnaffe@st.com
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479112050-14042-1-git-send-email-peppe.cavallaro@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Mon, 14 Nov 2016 09:27:27 +0100

> This subset of patches aim to fix the PTP support
> for the stmmac and especially for 4.x chip series.
> While setting PTP on an ST box with 4.00a Ethernet
> core, the kernel panics due to a broken settings
> of the descriptors. The patches review the
> register configuration, the algo used for configuring
> the protocol, the way to get the timestamp inside
> the RX/TX descriptors and, in the end, the statistics
> displayed by ethtool.
> 
> V2: RESEND all the patches adding the Acked-by.

Series applied, thanks.
