From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, RFT PATCH 1/2] dl2k: Add support for IP1000A-based cards
Date: Tue, 25 Aug 2015 14:04:30 -0700 (PDT)
Message-ID: <20150825.140430.663421843230467362.davem@davemloft.net>
References: <1440363988-12325-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	romieu@fr.zoreil.com, sorbica@icplus.com.tw
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440363988-12325-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Sun, 23 Aug 2015 23:06:27 +0200

> Add support for IP1000A chips to dl2k driver.
> IP1000A chip looks like a TC9020 with integrated PHY.
> 
> Tested with Asus NX1101.

You're saying the PHY support is incomplete, so gigabit isn't even
detected for these chips.

So in a way this is a regression of sorts.

Come back with these proposed changes once you have the PHY support
situation sorted out.

Thanks.
