From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Fwd: kernel 2.4.21]
Date: Wed, 23 Jul 2003 04:40:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723044027.152a298d.davem@redhat.com>
References: <1058634345.22000.2.camel@dhcp22.swansea.linux.org.uk>
	<20030719191723.0821227f.davem@redhat.com>
	<3F1E53F7.5000803@unixtech.be>
	<20030723023528.76b0f69c.davem@redhat.com>
	<3F1E58EE.5010109@unixtech.be>
	<20030723024648.2e4b6a62.davem@redhat.com>
	<3F1E71C1.8080302@unixtech.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Cedric Gavage <cedric.gavage@unixtech.be>
In-Reply-To: <3F1E71C1.8080302@unixtech.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 13:30:09 +0200
Cedric Gavage <cedric.gavage@unixtech.be> wrote:

> David S. Miller wrote:
> > Any chance you can try with the e100 driver instead of eepro100?
> Could I use it with these cards?

Yes, if anything, e100 works with more cards than
eepro100 does.  e100 is supported well, whereas I can't
remember the last time eepro100 had a change made to it :-)
