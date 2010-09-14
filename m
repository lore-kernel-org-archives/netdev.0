From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] cx82310_eth: allow empty URBs
Date: Mon, 13 Sep 2010 20:04:13 -0700 (PDT)
Message-ID: <20100913.200413.116373901.davem@davemloft.net>
References: <201009111740.18843.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009111740.18843.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Sat, 11 Sep 2010 17:40:16 +0200

> Empty received URBs are currently counted as errors but the device sends them
> sometimes as part of regular traffic - so remove this check.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Applied.
