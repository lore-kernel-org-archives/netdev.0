From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch] net/ieee80211: report hidden ESSIDs as zero-length, not "<hidden>"
Date: Wed, 12 Apr 2006 17:04:25 -0400
Message-ID: <20060412210416.GF12788@tuxdriver.com>
References: <1143215843.3417.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Zhu Yi <yi.zhu@intel.com>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:6665 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932248AbWDLVFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 17:05:43 -0400
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1143215843.3417.16.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 24, 2006 at 10:57:22AM -0500, Dan Williams wrote:
> <hidden> this is something that ieee80211 does that's completely wrong.
> Drivers need to report the _exact_ ESSID from the air in their scan
> results.  It's up to the user space app to deal with ESSID length of 0.

What is the outcome of this?  Did we get agreement on a patch?

John
-- 
John W. Linville
linville@tuxdriver.com
