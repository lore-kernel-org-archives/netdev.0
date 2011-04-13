From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [net-next-2.6 RFC PATCH v2 12/13] sky2: set ethtool set_phys_id
 on/off cycle frequency to 1/sec
Date: Wed, 13 Apr 2011 14:00:24 -0700
Message-ID: <20110413140024.4d21950e@nehalam>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
	<20110413195949.25901.86878.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bruce Allan <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37977 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932296Ab1DMVAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 17:00:46 -0400
In-Reply-To: <20110413195949.25901.86878.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Apr 2011 12:59:49 -0700
Bruce Allan <bruce.w.allan@intel.com> wrote:

> Physical identification frequency based on how it was done prior to the
> introduction of set_phys_id.  Compile tested only.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Stephen Hemminger <shemminger@linux-foundation.org>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Assume same for skge
