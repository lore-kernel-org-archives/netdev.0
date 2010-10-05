From: Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH] iwl3945: queue the right work if the scan needs to be
 aborted
Date: Wed, 6 Oct 2010 00:29:44 +0200
Message-ID: <20101006002944.4545cf32@schatten.dmk.lab>
References: <20101005084305.52a31ed4@schatten.dmk.lab>
	<20101005085717.GA18012@redhat.com>
	<20101005121242.79cdafc2@schatten.dmk.lab>
	<20101005104357.GB18833@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Chatre, Reinette" <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Berg, Johannes" <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Cahill, Ben M" <ben.m.cahill-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101005104357.GB18833-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 5 Oct 2010 12:43:58 +0200
Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> > > 
> > > However, I do not think we should go with that to -stable (below
> > > 2.6.36). IIRC warnings showed up in current 2.6.36-rc, because of
> > > some other changes in the code.
> > > 
> > > Stanislaw
Hello stable,

scrap this. I handed out a brown paper bag bug fix and if that doesn't
get into 2.6.36, it probably should go into 2.6.36.y. But let's see...

Regards,
Flo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
