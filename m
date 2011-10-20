From: wwguy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: iwlagn: WARN_ON() in iwl_get_idle_rx_chain_count()
Date: Thu, 20 Oct 2011 11:54:22 -0700
Message-ID: <1319136862.2111.3.camel@wwguy-ubuntu>
References: <20111014150219.GA20672@rere.qmqm.pl>
	 <1318606158.12009.2.camel@wwguy-ubuntu>
	 <20111014192105.GA23640@rere.qmqm.pl> <20111020185756.GA24185@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111020185756.GA24185-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-10-20 at 11:57 -0700, Micha=C5=82 Miros=C5=82aw wrote:
> On Fri, Oct 14, 2011 at 09:21:05PM +0200, Micha=C5=82 Miros=C5=82aw w=
rote:
> > On Fri, Oct 14, 2011 at 08:29:18AM -0700, wwguy wrote:
> > > Could you try the attach patch and see if it fix your problem.
> > [attached patch removed]
> > Backported and applied. I'll test it for couple of days.
>=20
> I haven't tripped on the warnings in those last days with your
> patch applied. I think the backported version should be included
> in 3.1.
>=20
Thank you for testing it, I will push it upstream into 3.1

Best Regards
Wey


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
