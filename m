From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] sky2: fix simple define thinko
Date: Tue, 13 May 2008 01:17:55 -0400
Message-ID: <48292483.6060104@garzik.org>
References: <20080506213435.25259.83781.stgit@jbrandeb-ich9b.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49373 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753487AbYEMFR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 01:17:58 -0400
In-Reply-To: <20080506213435.25259.83781.stgit@jbrandeb-ich9b.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Brandeburg wrote:
> noticed while browsing code, apparent thinko.  compile tested only.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Stephen Hemminger <shemminger@linux-foundation.org>
> ---
> 
>  drivers/net/sky2.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

applied


