From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Wed, 16 Jun 2004 13:50:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616205014.GB23617@bougret.hpl.hp.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com> <40CF263E.70009@home.nl> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <40D08769.3070106@home.nl> <1087412780.3351.34.camel@sfeldma-mobl2.dsl-verizon.net>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gertjan van Wingerde <gwingerde@home.nl>, netdev@oss.sgi.com,
        jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
Content-Disposition: inline
In-Reply-To: <1087412780.3351.34.camel@sfeldma-mobl2.dsl-verizon.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 16, 2004 at 12:06:21PM -0700, Scott Feldman wrote:
> 
> For example, do we really want to burden the user with the decision of
> whether they need to set a maximum fragment size?  Or what the
> sensitivity threshold should be?  The point is, we need to find the
> minimal set of settings to get the job done.

	For the record, those commands were added in 1997 for
sensitivity and 1999 for frag/rts. For the card of those ancient time,
setting those parameters was important, as the Access Point was not
pushing them to the cards.
	Have fun...

	Jean
