From: Dave Dillow <dave@thedillows.org>
Subject: Re: [RFC BK 0/22] xfrm offload v2: Add hardware assist for IPSEC
	crypto
Date: Thu, 20 Jan 2005 12:22:27 -0500
Message-ID: <1106241747.7097.5.camel@dillow.idleaire.com>
References: <Xine.LNX.4.44.0501171358170.20772-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0501171358170.20772-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[Sorry for the delay, my office at home got taken out Monday night...]

On Mon, 2005-01-17 at 14:00, James Morris wrote:
> On Mon, 10 Jan 2005, David Dillow wrote:
> 
> > * Only the 3Com 3CR990 family of NICs are supported. I don't have hardware
> > 	or documentation for the Intel cards.
> 
> Is documentation for the 3com card freely available?

Not to my knowledge, no. It should still be available under NDA, which
is how I got ahold of it.

> Also, are the cards still available on the market?  The 3com site says
> the 3CR990-TX-97 and -95 cards are discontinued.

You can still find some of those, even though they're discontinuted. The
family lives on in the 3CR990B-97 series, which are also supported by
the typhoon driver.
-- 
Dave Dillow <dave@thedillows.org>
