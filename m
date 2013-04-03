From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next 6/8] r8169: add a new chip for RTL8111G
Date: Wed, 3 Apr 2013 07:59:09 +0200
Message-ID: <20130403055909.GA26022@electric-eye.fr.zoreil.com>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com>
 <1364891022-3220-1-git-send-email-hayeswang@realtek.com>
 <1364891022-3220-6-git-send-email-hayeswang@realtek.com>
 <20130402222728.GA16612@electric-eye.fr.zoreil.com>
 <5A289D0C2A6C44158FB4CC5226F8E920@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5A289D0C2A6C44158FB4CC5226F8E920@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hayeswang <hayeswang@realtek.com> :
[...]
> Excuse me, I don't sure what is your question. Do you mean if the patch
> "[PATCH v2 net-next 5/8] r8169: Update the RTL8111G parameters" is necessary
> before the current patch? According to the settings from our hw engineers,
> some settings of the new chip are the same with the previous 8111g chip
> using the new parameters. It would work without patch #5. However, it is
> necessary to be updated finally, so I add this patch after patch #5.

I was wondering if some part of #5 would be subject to future changes or
reverted in the context of the new chipset (the global description of the
v2 series did not outline the changes in #5).

It completely answers the question. Sorry for the poor wording.

Thanks.

-- 
Ueimor
