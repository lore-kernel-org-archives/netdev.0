From: "Chad N. Tindel" <ctindel@falcon.csc.calpoly.edu>
Subject: Re: [Bonding-devel] Re: Bonding driver unreliable under high CPUload
Date: Tue, 17 Sep 2002 13:11:29 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.44.0209171311080.11147-100000@falcon.csc.calpoly.edu>
References: <3D878B73.6080503@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@digeo.com>,
   "Cureington, Tony" <tony.cureington@hp.com>,
   Pascal Brisset <pascal.brisset-ml@wanadoo.fr>,
   <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
In-Reply-To: <3D878B73.6080503@mandrakesoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > Will netif_carrier_ok(slave_dev) always work?  Do all drivers support the
> > __LINK_STATE_NOCARRIER flag?
>
>
> No.  Read again the precise language I used :)

Right, well thats what I thought.  But how can we do what Andrew wants?

Chad
