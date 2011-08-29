From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 18:03:48 -0400 (EDT)
Message-ID: <20110829.180348.1774953636752413432.davem@davemloft.net>
References: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4EE9@SACMVEXC2-PRD.hq.netapp.com>
	<20110829.143751.1153162956919885670.davem@davemloft.net>
	<4E5C0AB3.90401@panasas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	neilb-l3A5Bk7waGM@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E5C0AB3.90401-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Date: Mon, 29 Aug 2011 14:54:59 -0700

> I have a question about that. Are the dprints going to show the stack backtrace?

Yes, OOMs give full stack backtraces.

> If yes above? then I'm not sure I like it either, because am I'll be getting a full
> stack backtrace for every failed allocation?

They've been doing this for years, so obviously they haven't bothered you
enough to care up to this point.

All of this pushback is pure uneducated noise, please stop blocking progress
with poorly informed objections.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
