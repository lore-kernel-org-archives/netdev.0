From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Fri, 28 Jan 2005 13:45:19 -0800
Message-ID: <20050128134519.11a0e55d.davem@davemloft.net>
References: <1106932637.3778.92.camel@localhost.localdomain>
	<20050128100229.5c0e4ea1@dxpl.pdx.osdl.net>
	<1106937110.3864.5.camel@localhost.localdomain>
	<20050128105217.1dc5ef42@dxpl.pdx.osdl.net>
	<1106944492.3864.30.camel@localhost.localdomain>
	<20050128124517.36aa5e05.davem@davemloft.net>
	<20050128133408.49021343@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lorenzo@gnu.org, linux-kernel@vger.kernel.org, chrisw@osdl.org,
        netdev@oss.sgi.com, arjan@infradead.org, hlein@progressive-comp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050128133408.49021343@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2005 13:34:08 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> per-cpu would be the way to go here.

Does the sbox get somehow seeded from use to use?
If not, then yes that's the thing to do.
