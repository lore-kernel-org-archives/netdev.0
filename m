From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [6/6]: jenkins hash for neigh / Statistics
Date: Tue, 28 Sep 2004 10:44:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16729.9326.93269.422940@robur.slu.se>
References: <20040925005623.2faf8faf.davem@davemloft.net>
	<E1CBu70-00010X-00@gondolin.me.apana.org.au>
	<20040927121403.767e2308.davem@davemloft.net>
	<20040927222613.GE3236@sunbeam.de.gnumonks.org>
	<20040927160636.7741d973.davem@davemloft.net>
	<1096327658.1729.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Harald Welte <laforge@gnumonks.org>, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <1096327658.1729.19.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Stephen Hemminger writes:

 > > Harald Welte <laforge@gnumonks.org> wrote:
 > > 
 > > > As stated before, I would like to change rt_stat and ct_stat in order to
 > > > include a first 'template' line, too.  This way it is easier to write a
 > > > generic foo_stat program, that could deal with any of those statistics
 > > > files, even with new ones...  but this of course would break existing
 > > > rtstat binaries.  I personally  don't care, since it's a little-known
 > > > and little-used feature, which to my knowledge is in a lot of
 > > > distributions either non-existant [Debian] or incompatible [SuSE]. What
 > > > do you think?
 > > 
 > > I agree.  And while we're add it let's get a fixed rtstat into
 > > iproute2 and make sure that binary gets installed by default
 > > so maybe the dists will start shipping it properly.
 > 
 > I have the old one in the repository.

 I sent you the latest rtstat (Martin sent ctstat) during netfilter workshop. 
 Remember? Having a common foo_stat sounds like a good idea.

 Cheers.
						--ro
 
