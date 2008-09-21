From: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware restart.
Date: Mon, 22 Sep 2008 02:07:08 +0400
Message-ID: <20080921220708.GA31413@2ka.mipt.ru>
References: <20080921182835.GA11473@2ka.mipt.ru> <20080921140203.4698a2ee@infradead.org> <20080921210554.GA2135@2ka.mipt.ru> <200809220043.07345.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Denys Fedoryshchenko <denys-EpTYZhqHKuJnTudFRACr3A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200809220043.07345.denys-EpTYZhqHKuJnTudFRACr3A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 22, 2008 at 12:43:07AM +0300, Denys Fedoryshchenko (denys-EpTYZhqHKuJnTudFRACr3A@public.gmane.org) wrote:
> You are not right. I had totaly disfunctional Intel driver on two laptops and 
> reported about issue to Intel. Yes it took time, they took all debugs and 
> went coma mode (i was thinking that), but suddently i got mail from them, and 
> next kernel/firmware release worked for me flawlessly. So they did perfect 
> job.

I'm talking about current situation.

> Don't be negative and prepare yourself for giving long debug outputs. Patience 
> and only patience.

Just to be clear, did it take 4 years? :)

Anyway, I already made conclusions, as probably others: I will
experiment with different 'workarounds' for this bug, maybe I will
succeed, maybe Intel will decided to fix it, maybe LHC will crash the
world. Verbose warning about the bug was frowned upon, so its up to uses
to make a progress here...

-- 
	Evgeniy Polyakov
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
