From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3] net, wireless: overwrite default_ethtool_ops
Date: Tue, 22 Jan 2013 14:06:23 -0500 (EST)
Message-ID: <20130122.140623.481143614571024168.davem@davemloft.net>
References: <CAB=NE6XjvupJ5XO0EN0HVwdy61ECWL=Ey0g1gsNm+v8Sen=nsQ@mail.gmail.com>
	<20130121.160404.1007504714461228602.davem@davemloft.net>
	<20130122105618.GB2328@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130122105618.GB2328-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Tue, 22 Jan 2013 11:56:19 +0100

> On Mon, Jan 21, 2013 at 04:04:04PM -0500, David Miller wrote:
>> 
>> It's queued up for -stable already as is clearly seen at:
>> 
>> http://patchwork.ozlabs.org/user/bundle/2566/?state=*
> 
> Hmm, this link does not work for me (need user/password).

You just need to make a patchwork login, it's visible to any
registered user.

> Anyway, I marked cc -stable in v2 patch, but forgot that in v3.
> Committed patch does not include the mark, so I'll post patch
> to stable just in case.

Do NOT DO THIS, I do the submissions myself, by hand.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
