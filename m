From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [PATCH 2.6.10-rc1 14/15] wireless/orinoco: add minimal ethtool support
Date: Wed, 27 Oct 2004 14:01:30 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027040130.GB1676@zax>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098818684.9874.1.camel@dcbw.boston.redhat.com> <417EA97C.3070303@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, netdev@oss.sgi.com, jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <417EA97C.3070303@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2004 at 03:46:04PM -0400, Jeff Garzik wrote:
> Dan Williams wrote:
> >Update in-kernel orinoco wireless drivers to upstream CVS.
> >None of this is original code by Dan Williams, simply a
> >broken down patch set split-out from upstream orinoco CVS.
> >
> >o Add minimal ethtool support (Pavel Roskin)
> 
> should use ethtool_ops rather than manually handling the ioctl

Yes, we should, but no-one's done to work for the change.  I really
don't have time or resources myself - hence the long overdue merge in
the first place.

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
