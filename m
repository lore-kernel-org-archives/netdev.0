From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Conversions from kmalloc+memset to k(z|c)alloc.
Date: Tue, 18 Jul 2006 21:13:22 -0700 (PDT)
Message-ID: <20060718.211322.41951011.davem@davemloft.net>
References: <20060719011540.GD30823@lumumba.uhasselt.be>
	<20060719024805.GB3786@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: takis@lumumba.uhasselt.be, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, nico@cam.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17888
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932427AbWGSEM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 00:12:59 -0400
To: linville@tuxdriver.com
In-Reply-To: <20060719024805.GB3786@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 18 Jul 2006 22:48:05 -0400

> On Wed, Jul 19, 2006 at 03:15:40AM +0200, Panagiotis Issaris wrote:
> > From: Panagiotis Issaris <takis@issaris.org>
> > 
> > Conversions from kmalloc+memset to k(z|c)alloc.  The original memsets
> > did not clear out the entire allocated structure. To my unexperienced
> > eye, that seemed a bit fishy (or at least a bit weird and inconsistent).
> > 
> > Signed-off-by: Panagiotis Issaris <takis@issaris.org>
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Also applied, thanks a lot.
