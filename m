From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 09:27:48 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610.092748.115929981.davem@redhat.com>
References: <20030610061010.Y36963@shell.cyberus.ca>
	<200306101142.h5ABgssG004210@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@shell.cyberus.ca, ralph+d@istop.com, xerox@foonet.net,
	sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: chas@cmf.nrl.navy.mil
In-Reply-To: <200306101142.h5ABgssG004210@ginger.cmf.nrl.navy.mil>
List-Id: netdev.vger.kernel.org

   From: chas williams <chas@cmf.nrl.navy.mil>
   Date: Tue, 10 Jun 2003 07:41:01 -0400

   the bulk (by count) of the traffic seems to be in the 64-95 byte range.

Ok, time to deploy ATM everywhere to replace our IP routers :)
Sorry Chas, I couldn't resist... :)

Reagardless, there are some sites on the net that publish things
like BGP tables and traffic samples that people can use to do
performance testing on new algorithms.  I've read about it in
papers by Vern Paxson (he used it to do his Bro thing) and others.

I don't have a reference handy, anyone?  I think it's called the
IPMA project...
