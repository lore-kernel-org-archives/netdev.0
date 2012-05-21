From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [ANNOUNCE] iproute2 3.4.0
Date: Mon, 21 May 2012 14:48:26 -0700
Message-ID: <4FBAB82A.2070907@intel.com>
References: <20120521143740.2f6c0ecd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18248 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758971Ab2EUVs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2012 17:48:27 -0400
In-Reply-To: <20120521143740.2f6c0ecd@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/21/2012 2:37 PM, Stephen Hemminger wrote:
> To go with kernel release of 3.4 here is the update to
> iproute2. There wasn't a lot new features in this release, mostly
> manual pages and cleanups.
> 
> Source:
>   http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-3.4.0.tar.gz
> 
> Repository:
>   git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
> 
> Changes:
> 

Hi Stephen,

Any plans to push the new 'bridge' tool into the next release? We
have been using it internally and it works great. I also wanted
to add some code to it for managing the forwarding tables of the
embedded switching elements and have been experimenting with some
code to enable VEB/VEPA modes.

If you want me to help with testing or otherwise let me know.

Thanks,
John
