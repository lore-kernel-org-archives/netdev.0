From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: Boot lockups triggered by 'net: restore the original spinlock
	to protect unicast list'
Date: Wed, 5 Aug 2009 14:49:21 +0100
Message-ID: <20090805134921.GB16844@sirena.org.uk>
References: <20090805133659.GA3740@rakim.wolfsonmicro.main> <20090805134004.GG3897@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Meelis Roos <mroos@linux.ee>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:47428 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933568AbZHENtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 09:49:24 -0400
Content-Disposition: inline
In-Reply-To: <20090805134004.GG3897@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 05, 2009 at 03:40:05PM +0200, Jiri Pirko wrote:

> Try this patch
> http://marc.info/?l=linux-kernel&m=124945666109347&w=2

> That should fix this.

It does indeed, thanks.  FWIW

Tested-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
