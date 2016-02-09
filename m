From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Add Ethernet support on STM32F429
Date: Tue, 09 Feb 2016 04:52:14 -0500 (EST)
Message-ID: <20160209.045214.805916119264070573.davem@davemloft.net>
References: <1454511275-9791-1-git-send-email-alexandre.torgue@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcoquelin.stm32@gmail.com, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: alexandre.torgue@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454511275-9791-1-git-send-email-alexandre.torgue@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexandre TORGUE <alexandre.torgue@gmail.com>
Date: Wed,  3 Feb 2016 15:54:31 +0100

> STM32F429 Chip embeds a Synopsys 3.50a MAC IP.
> This series:
> 	-enhance current stmmac driver to control it (code already available) and 
> 	 adds basic glue for STM32F429 chip.
> 	-Enable basic Net config in kernel.
> 
> Note that DT patches are not present because STM32 pinctrl code is not
> yet avalaible.

Looks like this needs to be respun to deal with the warnings the kbuild
robot reported.

Thanks.
