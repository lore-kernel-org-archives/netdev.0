From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/9] ixgb: driver update to 1.0.109-k2
Date: Fri, 26 May 2006 21:23:47 -0400
Message-ID: <4477AA23.1010100@pobox.com>
References: <20060526165124.30514.78477.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58594 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964885AbWE0BXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 21:23:52 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060526165124.30514.78477.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Hi,
> 
> Here are the ixgb driver updates for 1.0.109-k2. This corresponds with
> the release of 1.0.109 on e1000.sf.net, and fixes several issues.
> 
> e1000 update will come soon...
> 
> 
> Summary:
> 
> [1] fix smp polling race condition
> [2] fix interface losing macaddr on ifdn/up
> [3] revert an unwanted fix regarding tso/descriptors
> [4] allocate only buffersize needed
> [5] remove lock access in the fast path
> [6] remove inlines, allow compiler to choose
> [7] replace netdev->priv with netdev_priv()
> [8] remove changelog
> [9] update version, dates
> 
> 
> These changes are available through git.
> 
> git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 ixgb-1.0.109-k2

pulled


