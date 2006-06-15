From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Thu, 15 Jun 2006 16:07:13 -0400
Message-ID: <20060615200709.GC32582@tuxdriver.com>
References: <20060610175010.GA4617@divinity> <20060610180850.GP7420@redhat.com> <20060611222719.GA13139@redhat.com> <20060611224054.GB13139@redhat.com> <20060611224954.GA2880@divinity> <20060612152434.GA14851@tuxdriver.com> <1150346713.26487.24.camel@dv> <4490ECDE.2030600@cube.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>, Dave Jones <davej@redhat.com>,
	netdev@vger.kernel.org, hermes@gibson.dropbear.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-70-61-120-52.midsouth.biz.rr.com ([70.61.120.52]:32516
	"EHLO ra.tuxdriver.com") by vger.kernel.org with ESMTP
	id S1031247AbWFOUIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 16:08:13 -0400
To: Faidon Liambotis <faidon@cube.gr>
Content-Disposition: inline
In-Reply-To: <4490ECDE.2030600@cube.gr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 15, 2006 at 08:15:10AM +0300, Faidon Liambotis wrote:

> Regarding the disabling of IDs, I could prepare a patch for orinoco_cs
> that would disable Prism2 support via a configuration option. Would that
> be helpful/acceptable?

I'm going to 'officially' drop this patch, while you and Pavel work-out
this issue.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
