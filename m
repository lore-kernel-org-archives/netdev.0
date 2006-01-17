From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: wireless: recap of current issues (stack)
Date: Tue, 17 Jan 2006 09:38:18 -0800
Message-ID: <20060117173818.GA19159@bougret.hpl.hp.com>
References: <20060113195723.GB16166@tuxdriver.com> <20060113213200.GG16166@tuxdriver.com> <200601131703.29677.chase.venters@clientec.com> <200601141451.16232.mbuesch@freenet.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chase Venters <chase.venters@clientec.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	Stefan Rompf <stefan@loplof.de>,
	Mike Kershaw <dragorn@kismetwireless.net>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Robert Hancock <hancockr@shaw.ca>,
	Alistair John Strachan <s0348365@sms.ed.ac.uk>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Denis Vlasenko <vda@ilport.com.ua>,
	Danny van Dyk <kugelfang@gentoo.org>,
	Stephen Hemminger <shemminger@osdl.org>, feyd <feyd@nmskb.cz>,
	Andreas Mohr <andim2@users.sourceforge.net>,
	Bas Vermeulen <bvermeul@blackstar.nl>,
	Jean Tourrilhes <jt@hpl.hp.com>, Daniel Drake <dsd@gentoo.org>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Phil Dibowitz <phil@ipom.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>,
	Patrick McHardy <kaber@trash.net>,
	Ingo Oeser <netdev@axxeo.de>,
	Harald Welte
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932251AbWAQRil@vger.kernel.org>
To: Michael Buesch <mbuesch@freenet.de>
Content-Disposition: inline
In-Reply-To: <200601141451.16232.mbuesch@freenet.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 14, 2006 at 02:51:14PM +0100, Michael Buesch wrote:
> On Saturday 14 January 2006 00:03, you wrote:
> > As an aside to this whole thing, I know we're talking about *kernel* wireless 
> > but it's worthless to most people without good userland support as well. 
> > Anyone have any thoughts and feelings on what things look like on the 
> > desktop? I think if we work closely with some desktop people, we can shepard 
> > in some wonderful new desktop support on top of the new netlink API.
> 
> I am in the KDE development and have (almost) full access to the KDE svn
> repository. Altought I did not do much coding on KDE apps recently,
> I will be able to help in WiFi support for KDE.
> The first thing I thought of, was a tray icon with basic information
> about the available interfaces and basic configuration
> capabilities.

	There is already at least 2 KDE applications for WiFi stuff,
and both are fully fledged (i.e. not just a signal meter) :
		http://websvn.kde.org/trunk/KDE/kdenetwork/wifi/
		http://websvn.kde.org/trunk/kdenonbeta/kifi/
	Note that I've used neither, so I don't know how good they are
and what features are missing. If you decide to write another apps,
please send me the link so I can add it on my web page.

> Greetings Michael.

	Have fun...

	Jean
