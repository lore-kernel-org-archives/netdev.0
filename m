From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 13:36:35 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.133635.84366118.davem@redhat.com>
References: <20030617200721.GA25773@netnation.com>
	<1055881034.3199.43.camel@tux.rsn.bth.se>
	<20030617203703.GB25773@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gandalf@wlug.westbo.se, Robert.Olsson@data.slu.se, ralph+d@istop.com,
   hadi@shell.cyberus.ca, xerox@foonet.net, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sim@netnation.com
In-Reply-To: <20030617203703.GB25773@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Tue, 17 Jun 2003 13:37:03 -0700
   
   Forwarding rate more than doubles when I turn off
   rp_filter off (Debian turns it on by default).

I have no idea why they do this, it's the stupidest thing
you can possibly do by default.

If we thought it was a good idea to turn this on by default
we would have done so in the kernel.

Does anyone have some cycles to spare to try and urge whoever is
repsponsible for this in Debian to leave the kernel's default setting
alone?

Thanks.
