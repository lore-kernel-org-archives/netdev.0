From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 09:38:11 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.093811.08342771.davem@redhat.com>
References: <Pine.LNX.4.51.0306092200150.28167@ns.istop.com>
	<20030610061010.Y36963@shell.cyberus.ca>
	<Pine.LNX.4.51.0306100828220.26498@ns.istop.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@shell.cyberus.ca, xerox@foonet.net, sim@netnation.com,
   fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com, ralph@istop.com
In-Reply-To: <Pine.LNX.4.51.0306100828220.26498@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ralph Doncaster <ralph@istop.com>
   Date: Tue, 10 Jun 2003 09:10:43 -0400 (EDT)

   No, as I said I'm moving ~30mbps and ~10kpps in and out of 2 3c905cx
   cards.

This is because the driver still uses PIO, I am rather sure of
this.
