From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Change MAC without bringing interface down
Date: 18 Aug 2003 11:10:48 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061219448.1031.20.camel@jzny.localdomain>
References: <20030818091312.GA4889@lapdog>
	 <20030818041911.358c3437.davem@redhat.com>  <20030818142455.GA1793@lapdog>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommi Virtanen <tv@debian.org>
In-Reply-To: <20030818142455.GA1793@lapdog>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


If you are going that approach then please if you have time do some
measurement on editing vs flushing with X number of cache entries.
go with X being a max of 200.

cheers,
jamal

On Mon, 2003-08-18 at 10:24, Tommi Virtanen wrote:

> 
> > This way, we don't have to fix up every single header cache
> > implementation, that's painful :(
> 
> 	I agree with that, though I am only interested in ethernet ;)
