From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 1/1] UDEV - Add 'udevlom' command line param to
 start_udev
Date: Wed, 24 Nov 2010 21:56:08 -0500
Message-ID: <20101124215608.6b0371b8.billfink@mindspring.com>
References: <20101103165505.GA3281@fedora-14-r710.oslab.blr.amer.dell.com>
	<20101103180500.GA7441@kroah.com>
	<20101105025848.GA14021@pws490.domsch.com>
	<20101115164714.GB7030@auslistsprd01.us.dell.com>
	<1289841399.2586.18.camel@bwh-desktop>
	<4CE18ACC.3020508@hp.com>
	<D3F292ADF945FB49B35E96C94C2061B90E4E367E@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rick Jones" <rick.jones2@hp.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"Matt Domsch" <Matt_Domsch@Dell.com>, "Greg KH" <greg@kroah.com>,
	"K, Narendra" <Narendra_K@Dell.com>,
	<linux-hotplug@vger.kernel.org>, <netdev@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90E4E367E@nsmail.netscout.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 Nov 2010, Loke, Chetan wrote:

> > Are folks sufficently confident that using anything other than "eth"
> > won't cause some unpleasant "our app always ass-u-me-d interfaces
> started with
> > 'eth'" situations?
> 
> Good point. I'm sure folks use 'eth' in their regex filters. Please
> ignore my obe/obn email.

If the 2 or 3 character name isn't a hard requirement, then
ethm for eth(ernet on )m(otherboard) would seem a natural
possibility.

					-Bill
