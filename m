From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Sat, 12 Feb 2005 23:29:28 +0100
Message-ID: <m11xblif93.fsf@muc.de>
References: <20050131201141.GA4879@elte.hu>
	<20050131232735.11236.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arjan@infradead.org, bunk@stusta.de, chrisw@osdl.org,
	davem@redhat.com, hlein@progressive-comp.com,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	shemminger@osdl.org, Valdis.Kletnieks@vt.edu
To: linux@horizon.com
In-Reply-To: <20050131232735.11236.qmail@science.horizon.com> (linux@horizon.com's
 message of "31 Jan 2005 23:27:35 -0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

linux@horizon.com writes:
>
> (The homebrew 15-bit block cipher in this code does show how much the
> world needs a small block cipher for some of these applications.)

Doesn't TEA fill this niche? It's certainly used for this in the Linux
kernel, e.g. in reiserfs (although I have my doubts it is really useful
there) 

-Andi
