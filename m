From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 3/6][8021q][2.4] Use VLAN tag set functionality in 8021q
 module
Date: Wed, 28 Jan 2004 11:40:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128114047.3d5e8817.davem@redhat.com>
References: <E791C176A6139242A988ABA8B3D9B38A03A9CCD5@hasmsx403.iil.intel.com>
	<200401281857.25642.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Shmuel Hen <shmulik.hen@intel.com>
In-Reply-To: <200401281857.25642.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 28 Jan 2004 18:57:25 +0200
Shmuel Hen <shmulik.hen@intel.com> wrote:

> On Monday 26 January 2004 19:42, Jeff Garzik wrote:
> > Shmuel Hen wrote:
> > > Also, speaking of the bonding changes queued in netdev-2.4, some
> > > of those have been queued there since 2.4.23 came out. Will those
> > > be pushed to Marcelo during 2.4.25 or do you intend to hold them
> > > until 2.4.26-preX starts?
> >
> > Sounds like DaveM and I will need to coordinate a bit, then.
> 
> By coordinate, do you mean that you'll take in all of our patches and 
> forward them to Dave at the appropriate time, or instead wait for 
> Dave to take in the first half (which is not bonding specific) and 
> only then take the last half ?

I think the best is to have me push the infrastructure into 2.6.3-pre1
and then Jeff can add the bonding bits to his tree.
