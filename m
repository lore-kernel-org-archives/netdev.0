From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v3 5/5] r8169: support RTL8411
Date: Thu, 5 Apr 2012 10:37:43 +0200
Message-ID: <20120405083743.GB32027@electric-eye.fr.zoreil.com>
References: <1333089184-1773-5-git-send-email-hayeswang@realtek.com> <1333090086-1815-1-git-send-email-hayeswang@realtek.com> <20120330072521.GA11548@electric-eye.fr.zoreil.com> <52E71C7B42A44FB1A8556BB6B75CD9A0@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52E71C7B42A44FB1A8556BB6B75CD9A0@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hayeswang <hayeswang@realtek.com> :
[...]
> There is nothing to do for rtl_init_jumbo_ops. It is all right for keeping
> NULL.

Ok, I'll add it to the commit message for future reference.

> Do I need to resend this patch?

No, I'll give it a short testing and forward to David.

We have a few weeks of net-next head. If there are further changes in sight,
you may consider planning for those before the cycle ends. Otherwise they
will experience a complete kernel cycle delay.

Thanks.

-- 
Ueimor

Will code drivers for food.
