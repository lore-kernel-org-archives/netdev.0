From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] Conversions from kmalloc+memset to k(z|c)alloc.
Date: Tue, 18 Jul 2006 22:48:05 -0400
Message-ID: <20060719024805.GB3786@tuxdriver.com>
References: <20060719011540.GD30823@lumumba.uhasselt.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, nico@cam.org,
	patrick@tykepenguin.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:63503 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932462AbWGSDGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 23:06:05 -0400
To: Panagiotis Issaris <takis@lumumba.uhasselt.be>
Content-Disposition: inline
In-Reply-To: <20060719011540.GD30823@lumumba.uhasselt.be>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 19, 2006 at 03:15:40AM +0200, Panagiotis Issaris wrote:
> From: Panagiotis Issaris <takis@issaris.org>
> 
> Conversions from kmalloc+memset to k(z|c)alloc.  The original memsets
> did not clear out the entire allocated structure. To my unexperienced
> eye, that seemed a bit fishy (or at least a bit weird and inconsistent).
> 
> Signed-off-by: Panagiotis Issaris <takis@issaris.org>

Signed-off-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville
linville@tuxdriver.com
