From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Route cache performance under stress
Date: Wed, 11 Jun 2003 21:48:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87he6wbdkz.fsf@deneb.enyo.de>
References: <Pine.LNX.4.44.0306101432530.21247-100000@netcore.fi>
	<20030610075702.I37165@shell.cyberus.ca>
	<Pine.LNX.4.51.0306101125500.21435@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi <hadi@shell.cyberus.ca>, Pekka Savola <pekkas@netcore.fi>,
   CIT/Paul <xerox@foonet.net>, "'Simon Kirby'" <sim@netnation.com>,
   "'David S. Miller'" <davem@redhat.com>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0306101125500.21435@ns.istop.com> (Ralph
 Doncaster's message of "Tue, 10 Jun 2003 11:29:18 -0400 (EDT)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ralph Doncaster <ralph@istop.com> writes:

>> Assuming the attacker has a 100mbps link to you, yes ;->
>
> A script kiddie 0wning a box with a FE connection is nothing.  During what
> was probably the worst DOS I got hit with, one of my upstream providers
> said they were seeing about 600mbps of traffic related to the attack.

Yes, these numbers keep growing.  By today's standards, 6000 Mbps
shouldn't be too surprising. 8-(

One of the servers I keep running was recently flooded with 1500-byte
UDP packets, Fast Ethernet line rate.  It definitely happens if your
pipes are fat enough.
