From: Simon Kelley <simon@thekelleys.org.uk>
Subject: Re: wireless: recap of current issues (stack)
Date: Sat, 14 Jan 2006 10:46:29 +0000
Message-ID: <43C8D685.70805@thekelleys.org.uk>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com> <20060113213200.GG16166@tuxdriver.com> <200601131703.29677.chase.venters@clientec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Benc <jbenc@suse.cz>, Stefan Rompf <stefan@loplof.de>,
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
	Michael Buesch <mbuesch@freenet.de>,
	Marcel Holtmann <marcel@holtmann.org>,
	Patrick McHardy <kaber@trash.net>,
	Ingo Oeser <netdev@axxeo.de>,
	Harald Welte <laforge@gnumonks.org>,
	Ben Greear <greearb@can
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751749AbWANKnV@vger.kernel.org>
To: Chase Venters <chase.venters@clientec.com>
In-Reply-To: <200601131703.29677.chase.venters@clientec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chase Venters wrote:

> As an aside to this whole thing, I know we're talking about *kernel* wireless 
> but it's worthless to most people without good userland support as well. 
> Anyone have any thoughts and feelings on what things look like on the 
> desktop? I think if we work closely with some desktop people, we can shepard 
> in some wonderful new desktop support on top of the new netlink API.
> 

An obvious place to start is the NetworkManager project. They should be 
asked the obvious "what do you need" and "does this provide it" 
questions. Dan Williams has been active recently producing small kernel 
patches which make the kernel side stuff work better with NM, so he 
might be a good contact to start with.

Cheers,

Simon.
