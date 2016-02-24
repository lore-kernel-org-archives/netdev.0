From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net v4] r8169:fix "rtl_counters_cond == 1 (loop: 1000,
 delay: 10)" log spam.
Date: Wed, 24 Feb 2016 22:52:30 +0100
Message-ID: <20160224215230.GA8013@electric-eye.fr.zoreil.com>
References: <1456294722-3596-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: Chunhao Lin <hau@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456294722-3596-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chunhao Lin <hau@realtek.com> :
[...]

Fine with me.

Is there any chance for the set of chipset dependent registers that
are safe to be read when in D3 state to be documented ?

-- 
Ueimor
