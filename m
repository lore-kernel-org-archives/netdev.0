From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 0/2] cfg80211: firmware and hardware version
Date: Thu, 1 Oct 2009 12:56:50 -0400
Message-ID: <20091001165649.GB2895@tuxdriver.com>
References: <20090924180048.14503.9579.stgit@tikku> <43e72e890909241320j592e347die8a14f8bdd962ffb@mail.gmail.com> <20090925044258.GA2722@tuxdriver.com> <da94abde0909250947k5084db85vccafe0d3e74e2ecf@mail.gmail.com> <43e72e890909250953r1714c79bsa679b96ca6f5797@mail.gmail.com> <20091001011340.GA3123@tuxdriver.com> <87fxa3qjt2.fsf@purkki.valot.fi> <20091001151820.GA2895@tuxdriver.com> <1254411199.2735.4.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254411199.2735.4.camel@achroite>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 01, 2009 at 04:33:19PM +0100, Ben Hutchings wrote:
> On Thu, 2009-10-01 at 11:18 -0400, John W. Linville wrote:
> [...]
> > > But here are the features which I doubt we will ever use:
> > > 
> > >         ethtool -s|--change DEVNAME     Change generic options
> > >                 [ speed %%d ]
> > >                 [ duplex half|full ]
> > >                 [ port tp|aui|bnc|mii|fibre ]
> > >                 [ autoneg on|off ]
> > >                 [ advertise %%x ]
> > >                 [ phyad %%d ]
> > >                 [ xcvr internal|external ]
> > >                 [ wol p|u|m|b|a|g|s|d... ]
> > >                 [ sopass %%x:%%x:%%x:%%x:%%x:%%x ]
> > >                 [ msglvl %%d ] 
> > >         ethtool -a|--show-pause DEVNAME Show pause options
> > >         ethtool -A|--pause DEVNAME      Set pause options
> > >                 [ autoneg on|off ]
> > >                 [ rx on|off ]
> > >                 [ tx on|off ]
> > 
> > I agree that the above are ethernet-specific.
> [...]
> 
> Message level isn't and WoL arguably isn't.  It's a shame that these
> original ethtool settings are still bundled together...

Oh, yes!  Missed those in the noise...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
