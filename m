From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: fix saddr checking bug in datagram_send_ctl()
Date: Wed, 21 Jan 2004 14:07:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040121140718.31deafeb.davem@redhat.com>
References: <1074683199.1172.26.camel@simulacron>
	<Pine.LNX.4.58.0401211657160.29787@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: aj@dungeon.inka.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0401211657160.29787@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 21 Jan 2004 17:03:07 +0200 (EET)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> I'm sorry, a bug had slipped into my link-local checking patch, which
> Andreas noticed.
> 
> Here is the fix.

Applied, thanks Ville.
