From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Tue, 06 Jan 2015 10:03:44 +0200
Message-ID: <87d26s1gkf.fsf@kamboji.qca.qualcomm.com>
References: <1420297188.2397.3.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420297188.2397.3.camel-IWqWACnzNjzz+pZb47iToQ@public.gmane.org> (Paul Bolle's message of
	"Sat, 03 Jan 2015 15:59:48 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org> writes:

> This reverts commit dddd60220f41775e634258efd1b54c6fa81ce706.
>
> The raison d'=C3=AAtre of commit dddd60220f41 ("ipw2200: select
> CFG80211_WEXT") was reverted in commit 2d36e008739e ("Revert "cfg8021=
1:
> make WEXT compatibility unselectable""). So revert this commit too.
>
> Signed-off-by: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>

Based on the discussion I have dropped this patch from my queue.

--=20
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
