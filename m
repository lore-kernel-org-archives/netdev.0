From: "David S. Miller" <davem@redhat.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Fri, 27 Jun 2003 17:19:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030627.171933.104040753.davem@redhat.com>
References: <3EFC9203.3090508@candelatech.com>
	<20030627.144426.71096593.davem@redhat.com>
	<1056755070.5463.12.camel@dhcp22.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, mbligh@aracnet.com, linux-kernel@vger.kernel.org,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: alan@lxorguk.ukuu.org.uk
In-Reply-To: <1056755070.5463.12.camel@dhcp22.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Alan Cox <alan@lxorguk.ukuu.org.uk>
   Date: 28 Jun 2003 00:04:30 +0100
   
   it means you can spot patterns, trends

I already spot patterns and trends when people retransmit the
bug/patch/whatever.  As do other people.

Frankly, people who aren't willing to maintain their patches
and retransmit them to me, do not matter as far as I am concerned.
If you don't want to put forth the effort, I do not want to interact
with you.  I feel the same way about bugs.

Linus has been saying this and doing it for years, and I've had to
learn the hard way that he's absolutely right in this regard.  If you
try to track everything, you accomplish nothing.  You will, however,
get overloaded and frustrated.  To scale one must reserve the right to
hit the delete key and it's _GONE_ not accumulating somewhere else.

We need social engineering.  If someone never gets their bug looked at
because they post absolute crap bug reports, that's a feature.  If
people spend all this effort making sense of such reports and fix them
_ANYWAYS_ the reporter will never learn to produce high quality bug
reports that are more useful to us.  That means the scarcest resource
we have is being used inefficiently.

That same goes for patches, and I've watched over time how this works.

This is another reasone that I hate when people privately email me
stuff, because I _WILL_ delete it and I _WILL_ lose it.  If you post
it to the lists, it gets accumulated somewhere but it doesn't clog
my mailbox and it doesn't create a backlog for me.  It also means that
if I'm sipping Mai Tai's in Hawaii other people will see and can react
to the report.
