From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: RE: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Wed, 27 May 2015 18:00:30 +0200
Message-ID: <2239047.Ns2P95dsQ1@storm>
References: <1719052.SGOfRAJhfQ@storm> <3606797.04xNxe9kJh@storm> <309B89C4C689E141A5FF6A0C5FB2118B78D8BD39@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:44448 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330AbbE0QAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 12:00:35 -0400
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B78D8BD39@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Aaron,

On Monday, 23. March 2015 22:37:08 Brown, Aaron F wrote:
> > >
> > > And with an internal reproduction of the issue I have created an
> > 
> > internal
> > 
> > > bug report, described my set of reproductions, referenced the similar
> > > external ones and assigned it to our current e1000e developer.
> > 
> > 
> > just wanted to quickly check if there has been any progress
> > since the internal bug report has been filed?
> 
> 
> No, no updates beyond a bit of investigation.

any news on this from the Intel labs?

Another two months passed ;) It would be nice to get rid
of the workaround that limits the max fragment size to 4096.

Thanks,
Thomas
