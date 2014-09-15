From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] DSA Cleanups
Date: Mon, 15 Sep 2014 17:24:49 -0400 (EDT)
Message-ID: <20140915.172449.812993009315281630.davem@davemloft.net>
References: <20140915165543.1261.2520.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, kernel@wantstofly.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605AbaIOVYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:24:52 -0400
In-Reply-To: <20140915165543.1261.2520.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 15 Sep 2014 12:59:14 -0400

> This patch series does two things, first it cleans up the tag_protocol and
> protocol ops being configured seperately.  Second it addresses the desire
> to split DSA away from relying on a MII bus.

This looks ok, series applied, thanks.
