From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 1/6] crc-itu-t: add bit-reversed calculation
Date: Thu, 4 Jun 2009 04:49:21 +0400
Message-ID: <20090604004921.GC32561@doriath.ww600.siemens.net>
References: <1244021629-18409-1-git-send-email-dbaryshkov@gmail.com> <1244021629-18409-2-git-send-email-dbaryshkov@gmail.com> <1244033004.21215.4.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, davem@davemloft.net,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Sergey Lapin <slapin@ossfans.org>,
	Darren Salt <linux@youmustbejoking.demon.co.uk>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:55208 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756504AbZFDAtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 20:49:36 -0400
Content-Disposition: inline
In-Reply-To: <1244033004.21215.4.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2009 at 01:43:24PM +0100, Ben Hutchings wrote:
> On Wed, 2009-06-03 at 13:33 +0400, Dmitry Eremin-Solenikov wrote:
> [...] 
> > +/**
> > + * crc_itu_t_bitreversed - Compute the CRC-ITU-T for the data buffer;
> > + * the buffer content is assumed to be bit-reversed
> [...]
> 
> This short description spills onto two lines which is invalid and breaks
> the generation of docs.  Sorry to point this out after recommending the
> patch to you.
> 
> I've changed the description to "crc_itu_t_bitreversed - Compute the
> CRC-ITU-T for a bit-reversed data buffer" all on one line.

Anyway, this patch isn't necessary for the first round of patches, we
are submitting now (got in by a mistake).


-- 
With best wishes
Dmitry

