From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH v2 net-next 6/8] r8169: add a new chip for RTL8111G
Date: Wed, 3 Apr 2013 11:03:45 +0800
Message-ID: <5A289D0C2A6C44158FB4CC5226F8E920@realtek.com.tw>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com> <1364891022-3220-1-git-send-email-hayeswang@realtek.com> <1364891022-3220-6-git-send-email-hayeswang@realtek.com> <20130402222728.GA16612@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130402222728.GA16612@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Wednesday, April 03, 2013 6:27 AM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH v2 net-next 6/8] r8169: add a new chip 
> for RTL8111G
> 
> Hayes Wang <hayeswang@realtek.com> :
> > Add a new chip for RTL8111G series.
> 
> It does not need any of the workarounds in patch #5, right ?
 
Excuse me, I don't sure what is your question. Do you mean if the patch "[PATCH
v2 net-next 5/8] r8169: Update the RTL8111G parameters" is necessary before the
current patch? According to the settings from our hw engineers, some settings of
the new chip are the same with the previous 8111g chip using the new parameters.
It would work without patch #5. However, it is necessary to be updated finally,
so I add this patch after patch #5.
 
Best Regards,
Hayes
