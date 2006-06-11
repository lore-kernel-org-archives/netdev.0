From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Sun, 11 Jun 2006 18:31:40 -0400
Message-ID: <20060611223140.GB1163@skunkworks.cabal.ca>
References: <20060610175010.GA4617@divinity> <20060610180850.GP7420@redhat.com> <20060611222719.GA13139@redhat.com> <20060611224054.GB13139@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Faidon Liambotis <faidon@cube.gr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stout.engsoc.carleton.ca ([134.117.69.22]:14734 "EHLO
	stout.engsoc.carleton.ca") by vger.kernel.org with ESMTP
	id S1751119AbWFKWpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 18:45:44 -0400
To: Dave Jones <davej@redhat.com>
Content-Disposition: inline
In-Reply-To: <20060611224054.GB13139@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 11, 2006 at 06:40:54PM -0400, Dave Jones wrote:
> Under hostap, it's a brick, it won't even report any scanning results.
> 

Did you switch it into managed mode? The hostap driver, iirc, defaults
to running in master (AP) mode.

Cheers,
	Kyle
