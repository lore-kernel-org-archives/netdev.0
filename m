From: Thomas Gleixner <tglx@linutronix.de>
Subject: RE: Request for stable inclusion
Date: Wed, 30 Apr 2014 22:37:28 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1404302237070.6261@ionos.tec.linutronix.de>
References: <alpine.DEB.2.02.1404302055200.6261@ionos.tec.linutronix.de>  <2B0E3F215D1AB84DA946C8BEE234CCC9370ECAF9@ORSMSX101.amr.corp.intel.com> <1398887800.29914.183.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Ertman, DavidX M" <davidx.m.ertman@intel.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:55725 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759431AbaD3UhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 16:37:19 -0400
In-Reply-To: <1398887800.29914.183.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Apr 2014, Eric Dumazet wrote:

> On Wed, 2014-04-30 at 19:40 +0000, Ertman, DavidX M wrote:
> 
> > The commit that caused the issue went into net-next on June 21, 2013.  So at least 3.11 and forward, and probably 3.10.
> 
> There is a way to know exactly the cut point :
> 
> $ git describe --contains da1e2046e5
> v3.12-rc1~132^2~445^2~6

So 3.12+ is affected.
