From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: RE: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Sat, 30 May 2015 01:18:44 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B78DDC307@ORSMSX101.amr.corp.intel.com>
References: <1719052.SGOfRAJhfQ@storm> <3606797.04xNxe9kJh@storm>
 <309B89C4C689E141A5FF6A0C5FB2118B78D8BD39@ORSMSX101.amr.corp.intel.com>
 <2239047.Ns2P95dsQ1@storm>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7838 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751420AbbE3BSq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 21:18:46 -0400
In-Reply-To: <2239047.Ns2P95dsQ1@storm>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Thomas Jarosch [mailto:thomas.jarosch@intra2net.com]
> Sent: Wednesday, May 27, 2015 9:01 AM
> To: Brown, Aaron F
> Cc: Kirsher, Jeffrey T; 'Linux Netdev List'; Eric Dumazet; e1000-devel
> Subject: Re: RE: [bisected regression] e1000e: "Detected Hardware Unit
> Hang"
> 
> Hi Aaron,
> 
> On Monday, 23. March 2015 22:37:08 Brown, Aaron F wrote:
> > > >
> > > > And with an internal reproduction of the issue I have created an
> > >
> > > internal
> > >
> > > > bug report, described my set of reproductions, referenced the
> similar
> > > > external ones and assigned it to our current e1000e developer.
> > >
> > >
> > > just wanted to quickly check if there has been any progress
> > > since the internal bug report has been filed?
> >
> >
> > No, no updates beyond a bit of investigation.
> 
> any news on this from the Intel labs?

Nothing significant.  Another one of our testers (whom works more closely with the current e1000e driver owner than I) has managed to replicate it on several systems and I know the developer spent some time poking around the setup, but I don't think he's found the root cause yet and has been busy chasing a number of other issues.

> 
> Another two months passed ;) It would be nice to get rid
> of the workaround that limits the max fragment size to 4096.
> 
> Thanks,
> Thomas
