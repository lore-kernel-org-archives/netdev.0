From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3] net, wireless: overwrite default_ethtool_ops
Date: Tue, 22 Jan 2013 11:56:19 +0100
Message-ID: <20130122105618.GB2328@redhat.com>
References: <1357934432.2643.4.camel@bwh-desktop.uk.solarflarecom.com>
 <20130111.155936.1799008114956712424.davem@davemloft.net>
 <CAB=NE6XjvupJ5XO0EN0HVwdy61ECWL=Ey0g1gsNm+v8Sen=nsQ@mail.gmail.com>
 <20130121.160404.1007504714461228602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130121.160404.1007504714461228602.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 21, 2013 at 04:04:04PM -0500, David Miller wrote:
> 
> It's queued up for -stable already as is clearly seen at:
> 
> http://patchwork.ozlabs.org/user/bundle/2566/?state=*

Hmm, this link does not work for me (need user/password).

Anyway, I marked cc -stable in v2 patch, but forgot that in v3.
Committed patch does not include the mark, so I'll post patch
to stable just in case.

Thanks
Stanislaw 
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
