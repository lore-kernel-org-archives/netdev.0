From: Amit Kale <amitkale@netxen.com>
Subject: Re: NetXen driver name
Date: Mon, 12 Feb 2007 13:33:16 +0530
Message-ID: <200702121333.16199.amitkale@netxen.com>
References: <200702082152.19772.amitkale@netxen.com> <p734ppw349e.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:47321 "EHLO
	svr68.ehostpros.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964811AbXBLJRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 04:17:09 -0500
In-Reply-To: <p734ppw349e.fsf@bingen.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The already released kernel contains a broken driver.  It broke due to some 
code rearrangement changes someone submitted to fix sparse warnings.

-Amit

On Thursday 08 February 2007 23:45, Andi Kleen wrote:
> Amit Kale <amitkale@netxen.com> writes:
> > Hi,
> >
> > NetXen ethernet driver present in 2.6.20 has name "netxen_nic". The
> > product itself is refered to as "nx_nic". To make it inline with the
> > product, would it be a good idea to change the name of the driver to
> > "nx_nic"?
>
> When it's already in a released kernel it's a little late to rename the
> module. You would cause upgrade pain to users who have hardcoded the module
> name.
>
> -Andi
