From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH v6 0/6] Add Ethernet support on STM32F429
Date: Mon, 09 May 2016 15:06:34 -0400 (EDT)
Message-ID: <20160509.150634.213732321950308841.davem@davemloft.net>
References: <1462789899-13153-1-git-send-email-alexandre.torgue@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcoquelin.stm32@gmail.com, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	robh@kernel.org, manabian@gmail.com, wens@csie.org
To: alexandre.torgue@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462789899-13153-1-git-send-email-alexandre.torgue@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexandre TORGUE <alexandre.torgue@gmail.com>
Date: Mon,  9 May 2016 12:31:33 +0200

> STM32F429 Chip embeds a Synopsys 3.50a MAC IP.
> This series:
>  -enhance current stmmac driver to control it (code already
> available) and adds basic glue for STM32F429 chip.
>  -Enable basic Net config in kernel.

I assume this will go via the ARM tree, for the networking bits:

Acked-by: David S. Miller <davem@davemloft.net>
