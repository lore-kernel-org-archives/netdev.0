From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: stmmac: add BQL support
Date: Mon, 26 Jan 2015 15:22:53 -0800 (PST)
Message-ID: <20150126.152253.1228699160011707119.davem@davemloft.net>
References: <1421863647-20048-1-git-send-email-b.galvani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, f.fainelli@gmail.com, dave.taht@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: b.galvani@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421863647-20048-1-git-send-email-b.galvani@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Beniamino Galvani <b.galvani@gmail.com>
Date: Wed, 21 Jan 2015 19:07:27 +0100

> Add support for Byte Queue Limits to the STMicro MAC driver.
> 
> Tested on a Amlogic S802 quad Cortex-A9 board, where the use of BQL
> decreases the latency of a high priority ping from ~12ms to ~1ms when
> the 100Mbit link is saturated by 20 TCP streams.
> 
> Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>

Applied.
