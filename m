From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Mon, 1 Dec 2003 16:08:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201160811.70904c29.davem@redhat.com>
References: <20031201155005.1c515793.davem@redhat.com>
	<Pine.LNX.4.44.0312020206100.2728-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0312020206100.2728-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Dec 2003 02:07:00 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> 
> On Mon, 1 Dec 2003, David S. Miller wrote:
> 
> > This packet we are reacting to for PMTU purposes could only
> > have come from us if the TOS matches precisely.
> 
> 	Ops, ip_rt_redirect matches output route to, hm, lets think
> again about it...

Right.

I've rewritten emails in this thread probably 3 or 4 times
each before actually sending them out, so don't feel bad
since my mistakes have been merely hidden :)
