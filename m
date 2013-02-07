From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/5] r8169: Update the RTL8111G parameters
Date: Thu, 7 Feb 2013 01:03:07 +0100
Message-ID: <20130207000307.GC2784@electric-eye.fr.zoreil.com>
References: <1360161987-3268-1-git-send-email-hayeswang@realtek.com> <1360161987-3268-4-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1360161987-3268-4-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> - replace rtl8168g-1.fw with rtl8168g-2.fw which support new method.
> - fix PHY power down is useless.
> - disable rx early which causes the rx abnormal.
> - fix the conflict between jumbo frame and flow control.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

It seems ok.

-- 
Ueimor
