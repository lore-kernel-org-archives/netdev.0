From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 13:49:24 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.134924.119862290.davem@redhat.com>
References: <20030617203703.GB25773@netnation.com>
	<20030617.133635.84366118.davem@redhat.com>
	<20030617205101.GD25773@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gandalf@wlug.westbo.se, Robert.Olsson@data.slu.se, ralph+d@istop.com,
   hadi@shell.cyberus.ca, xerox@foonet.net, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sim@netnation.com
In-Reply-To: <20030617205101.GD25773@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Tue, 17 Jun 2003 13:51:01 -0700
   
   Specific firewall rules would have to be created otherwise.  And
   the overhead only really shows when the routing table is large,
   right?

rp filter breaks things... just like firewalls break things...

so just like a user enables firewall rules by himself, he may
enable rp filter by himself...
