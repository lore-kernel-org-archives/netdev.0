From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [PATCH 2.6.10-rc1 4/15] wireless/orinoco: Update orinoco changelog and module parameters
Date: Wed, 27 Oct 2004 13:15:51 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027031551.GI7925@zax>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098816355.3663.50.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1098816355.3663.50.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2004 at 02:45:55PM -0400, Dan Williams wrote:
> Update in-kernel orinoco wireless drivers to upstream CVS.
> None of this is original code by Dan Williams, simply a
> broken down patch set split-out from upstream orinoco CVS.
> 
> o Update orinoco changelog and module parameters

I don't think it's a good idea to apply this in the middle of the
others - it implies all the things in the changelog have gone in,
which they haven't, yet.

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
