From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fm10k: Fix missing braces after if statement
Date: Wed, 03 Jun 2015 23:57:51 -0700 (PDT)
Message-ID: <20150603.235751.1703498220892447151.davem@davemloft.net>
References: <20150604015219.2895.80478.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44457 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbbFDG5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 02:57:52 -0400
In-Reply-To: <20150604015219.2895.80478.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 03 Jun 2015 18:53:17 -0700

> While reviewing the code I noticed that one of the commits added an if
> statement followed by a for loop, but the if statement was missing the
> braces around the loop.  This change corrects the coding style error.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

I assume that I will get this via Jeff.
