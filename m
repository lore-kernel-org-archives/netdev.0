From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 6/6] r8169: support RTL8111E-VL
Date: Tue, 5 Jul 2011 20:56:26 +0200
Message-ID: <20110705185626.GF5105@electric-eye.fr.zoreil.com>
References: <1309859095-32031-1-git-send-email-hayeswang@realtek.com> <1309859095-32031-6-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1309859095-32031-6-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
[...]
> +	rtl_writephy(tp, 0x1e, 0x002D);
                                   ^^ 2d :o)

Some rtl_eri_write probably deserve to be tabulated. It can wait though.

-- 
Ueimor
