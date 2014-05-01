From: "Ertman, DavidX M" <davidx.m.ertman@intel.com>
Subject: RE: Request for stable inclusion
Date: Thu, 1 May 2014 14:56:53 +0000
Message-ID: <2B0E3F215D1AB84DA946C8BEE234CCC9370ECD71@ORSMSX101.amr.corp.intel.com>
References: <alpine.DEB.2.02.1404302055200.6261@ionos.tec.linutronix.de>
  <2B0E3F215D1AB84DA946C8BEE234CCC9370ECAF9@ORSMSX101.amr.corp.intel.com>
 <1398887800.29914.183.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.DEB.2.02.1404302237070.6261@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "stable@vger.kernel.org" <stable@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1404302237070.6261@ionos.tec.linutronix.de>
Content-Language: en-US
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Thomas Gleixner [mailto:tglx@linutronix.de]
> Sent: Wednesday, April 30, 2014 1:37 PM
> To: Eric Dumazet
> Cc: Ertman, DavidX M; stable@vger.kernel.org; Kirsher, Jeffrey T;
> netdev@vger.kernel.org
> Subject: RE: Request for stable inclusion
> 
> On Wed, 30 Apr 2014, Eric Dumazet wrote:
> 
> > On Wed, 2014-04-30 at 19:40 +0000, Ertman, DavidX M wrote:
> >
> > > The commit that caused the issue went into net-next on June 21, 2013.
> So at least 3.11 and forward, and probably 3.10.
> >
> > There is a way to know exactly the cut point :
> >
> > $ git describe --contains da1e2046e5
> > v3.12-rc1~132^2~445^2~6
> 
> So 3.12+ is affected.

Yes, sorry about that.  I was looking at when it got committed into an internal queue as opposed to taken into Linus's tree.  Silly mistake.

Dave Ertman
