From: "David S. Miller" <davem@redhat.com>
Subject: Re: 3c59x
Date: Tue, 10 Jun 2003 10:14:52 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.101452.35033262.davem@redhat.com>
References: <20030610162342.GB1959@gtf.org>
	<20030610.100209.70199702.davem@redhat.com>
	<20030610171617.GC1959@gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, bogdan.costescu@iwr.uni-heidelberg.de, hadi@shell.cyberus.ca,
   ralph+d@istop.com, xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <20030610171617.GC1959@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jeff Garzik <jgarzik@pobox.com>
   Date: Tue, 10 Jun 2003 13:16:17 -0400

   On Tue, Jun 10, 2003 at 10:02:09AM -0700, David S. Miller wrote:
   > This means end users don't see the benefit, so I definitely
   > prefer Andi's idea.
   
   Making every IO a conditional branch?  Ug.
   
A PIO costs hundreds if not thousands of instructions!
Come on Jeff, get real :-)
