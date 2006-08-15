From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: bonding: cannot remove certain named devices
Date: Tue, 15 Aug 2006 16:26:06 -0700
Message-ID: <Pine.CYG.4.58.0608151623560.508@mawilli1-desk2.amr.corp.intel.com>
References: <20060815214914.GA5307@nostromo.devel.redhat.com><Pine.CYG.4.58.0608151532070.2316@mawilli1-desk2.amr.corp.intel.com><20060815154444.286e12ed@localhost.localdomain>
 <20060815.155612.111203542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: shemminger@osdl.org,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	notting@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24732 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1750786AbWHOX0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 19:26:23 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060815.155612.111203542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 15 Aug 2006, David Miller wrote:
>
> I agree that whitespace in device names push the limits of sanity.
>
> But if we believe that, we should enforce it in dev_valid_name().
>
> Does anyone really mind if I add the whitespace check there?
>

I have no objections.  It would certainly make life easier.

OTOH, "push[ing] the limits of sanity" probably describes half of the
subscribers to netdev.  But that's neither here nor there.

-Mitch
