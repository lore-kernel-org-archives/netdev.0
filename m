From: Shmuel Hen <shmulik.hen@intel.com>
Subject: Re: [PATCH 3/6][8021q][2.4] Use VLAN tag set functionality in 8021q module
Date: Mon, 26 Jan 2004 15:22:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401261522.14126.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A02A46612@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="tscii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A02A46612@hasmsx403.iil.intel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 22 January 2004 20:06, David S. Miller wrote:
> > > On Thu, 22 Jan 2004 Shmuel Hen <shmulik.hen@intel.com> wrote:
> > > > Make the regular/HW accelerated xmit functions in the 8021q
> > > > module use the new set VLAN tag functionality to reduce code
> > > > duplication.
> > >
> > > I'm fine with this and the ARP change, I am pretty sure.
> > >
> > > But we have way too much stuff pending for the next 2.6.x release,
> > > so I'm going to defer adding these changes until Linus puts
> > > something final out.
> > >
> > > Please resend these two changes after he does a release.
> >
> > Fair enough. What about 2.4 ?
>
> Sure, send it once 2.4.26-preX starts up.

Jeff,

Since the last 3 patches from this set depend on the acceptance of
the first 3, and because they are also based on previous changes in
bonding that are queued in the netdev-2.4/2.6 BK trees, do you have
a problem accepting all 6 patches into the netdev trees?

Also, speaking of the bonding changes queued in netdev-2.4, some of
those have been queued there since 2.4.23 came out. Will those be
pushed to Marcelo during 2.4.25 or do you intend to hold them until
2.4.26-preX starts?

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
