From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: [PATCH 3/6][8021q][2.4] Use VLAN tag set functionality in 8021q module
Date: Sun, 25 Jan 2004 14:28:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C96A4@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>, <bonding-devel@lists.sourceforge.net>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----Original Message-----
From: David S. Miller [mailto:davem@redhat.com]
Sent: Thursday, January 22, 2004 8:07 PM
To: Hen, Shmulik
Cc: netdev@oss.sgi.com; bonding-devel@lists.sourceforge.net
Subject: Re: [PATCH 3/6][8021q][2.4] Use VLAN tag set functionality in 8021q module

> On Thu, 22 Jan 2004 17:57:19 +0200
> Shmuel Hen <shmulik.hen@intel.com> wrote:
> 
> > Make the regular/HW accelerated xmit functions in the 8021q module
> > use the new set VLAN tag functionality to reduce code duplication.
> 
> I'm fine with this and the ARP change, I am pretty sure.
> 
> But we have way too much stuff pending for the next 2.6.x release,
> so I'm going to defer adding these changes until Linus puts something
> final out.
> 
> Please resend these two changes after he does a release.

Fair enough. What about 2.4 ?

Thanks,
Shmulik.
