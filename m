From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/5] r8169: modify pll power function
Date: Wed, 28 Mar 2012 00:54:07 +0200
Message-ID: <20120327225407.GB22177@electric-eye.fr.zoreil.com>
References: <1332834834-5185-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1332834834-5185-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Adjust r810x_pll_power_down, r810x_pll_power_up, and r8168_pll_power_up.
> Always power up device during rtl_open.
> For r810x, turn off more power when the WOL is disabled.

Would the "Always power up" part qualify as a "fix something" change ?

-- 
Ueimor
