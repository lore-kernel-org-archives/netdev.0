From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating
 master'ssettings toslaves
Date: Tue, 12 Aug 2003 07:04:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812070414.1e8a5e63.davem@redhat.com>
References: <E791C176A6139242A988ABA8B3D9B38A0251E69F@hasmsx403.iil.intel.com>
	<200308121703.15567.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, laurent.deniel@thalesatm.com, jgarzik@pobox.com,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: <200308121703.15567.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 12 Aug 2003 17:03:15 +0300
Shmulik Hen <shmulik.hen@intel.com> wrote:

> > One of the great things about what Jamal spends his time working
> > on is finally a strict seperation of the control layer from
> > everything else.  And part of this is moving all of the control
> > logic into userspace. Once that is accomplished, I can have my
> > toilet flush every time a TCP packet is routed through my system
> > and this won't crap up the kernel.
> 
> What scope are we talking about here ?
> 2.4 ?  2.6 ?  2.7 ?  other ?
> Our current aim is 2.4 and 2.6.

Jamal's work is longer term, I'll let him answer your other
questions.
