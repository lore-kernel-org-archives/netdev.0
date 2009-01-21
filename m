From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] e1000: drop lltx, remove unnecessary lock
Date: Wed, 21 Jan 2009 14:40:38 -0800 (PST)
Message-ID: <20090121.144038.151480856.davem@davemloft.net>
References: <20090121083407.538.47112.stgit@lost.foo-projects.org>
	<20090121223418.GA8557@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40054
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753252AbZAUWkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 17:40:36 -0500
In-Reply-To: <20090121223418.GA8557@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 22 Jan 2009 09:34:18 +1100

> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> > LLTX is deprecated, don't use it.  This completes the removal of LLTX from
> > the Intel Network drivers.
> > 
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Awesome work Jeff :)

Indeed, I'll be applying these anti-LLTX patches for sure :)
