From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Mon, 3 Dec 2007 07:34:39 -0800
Message-ID: <20071203073439.7fe05875@laptopd505.fenrus.org>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca>
	<20071201111736.297dd99a@freepuppy.rosehill>
	<20071201163035.321fd554@freepuppy.rosehill>
	<475227B1.2060802@rtr.ca>
	<1196670255.4127.21.camel@rukbat>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Lord <lkml@rtr.ca>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: Romano Giannetti <romanol@upcomillas.es>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752674AbXLCPgr@vger.kernel.org>
In-Reply-To: <1196670255.4127.21.camel@rukbat>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 03 Dec 2007 09:24:15 +0100
Romano Giannetti <romanol@upcomillas.es> wrote:

> 
> 
> On Sat, 2007-12-01 at 22:34 -0500, Mark Lord wrote:
> > Stephen Hemminger wrote:.
> > >>
> > > I spoke too soon earlier, ndiswrapper builds and loads against
> > > current 2.6.24-rc3. Vmware and proprietary VPN software probably
> > > do not. Once again I don't give a damn, but the enterprise distro
> > > vendors certainly care.
> > ...
> > 
> > Naw, enterprise (or any other) distro vendors shouldn't have any
> > issues here, since they can just patch their kernels around any
> > issues.
> 
> Please pardon me for jumping in; 

> 
> What I think is that every time VMware or (worst) ndiswrapper breaks,

if you had read the thread... ndiswrapper doesn't break, and vmware
driver had some bugs that, once fixed, no no longer break either....


-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
