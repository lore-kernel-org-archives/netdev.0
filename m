From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Wed, 16 Jun 2004 16:11:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616231113.GA31351@bougret.hpl.hp.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com> <40CF263E.70009@home.nl> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <40D08769.3070106@home.nl> <20040616204248.GA23617@bougret.hpl.hp.com> <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com> <40D0D265.3070804@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gertjan van Wingerde <gwingerde@home.nl>, sfeldma@pobox.com,
        netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D0D265.3070804@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 16, 2004 at 07:06:13PM -0400, Jeff Garzik wrote:
> Jean Tourrilhes wrote:
> >	I think you did not understood my idea at all.
> >	If you build a set of generic wrappers and hook them in the
> >iw_handler table, you could trivially add the features you feel are
> >missing into those wrappers. Those wrappers would expose whatever API
> >you choose to the driver, call your struct wireless_ops for example.
> 
> That doesn't help anything.  Wrappers add code, while not solving the 
> following problems...

	You need to start somewhere. This allow you to experiment with
the API simply until you get it to the point you like it.

	Jean
