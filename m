From: Chris Wedgwood <cw@f00f.org>
Subject: Re: [PATCH] fix tcp_default_win_scale.
Date: Wed, 7 Jul 2004 00:50:27 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040707075027.GC17205@taniwha.stupidest.org>
References: <20040629222751.392f0a82.davem@redhat.com> <20040630152750.2d01ca51@dell_ss3.pdx.osdl.net> <20040630153049.3ca25b76.davem@redhat.com> <20040701133738.301b9e46@dell_ss3.pdx.osdl.net> <20040701140406.62dfbc2a.davem@redhat.com> <20040702013225.GA24707@conectiva.com.br> <20040706093503.GA8147@outpost.ds9a.nl> <20040706114741.1bf98bbe@dell_ss3.pdx.osdl.net> <20040706132426.097f71e6.davem@redhat.com> <20040706231600.GA18181@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>,
	Stephen Hemminger <shemminger@osdl.org>, ahu@ds9a.nl,
	acme@conectiva.com.br, netdev@oss.sgi.com,
	alessandro.suardi@oracle.com, phyprabab@yahoo.com,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040706231600.GA18181@wotan.suse.de>
List-Id: netdev.vger.kernel.org

On Wed, Jul 07, 2004 at 01:16:00AM +0200, Andi Kleen wrote:

> [btw it's quite possible that this isn't a firewall, but also
> some kind of header compression that is doing the wrong thing]

... or some kind of nasty intrusive bandwidth molesting device like a
PacketShaper...


   --cw
