From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] poll: Avoid extra wakeups
Date: Tue, 28 Apr 2009 02:15:50 -0700 (PDT)
Message-ID: <20090428.021550.187592488.davem@davemloft.net>
References: <49F3308B.1030507@cosmosbay.com>
	<20090426.020411.157511269.davem@davemloft.net>
	<49F43B8F.2050907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux.com, jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45255
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754970AbZD1JP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 05:15:56 -0400
In-Reply-To: <49F43B8F.2050907@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sun, 26 Apr 2009 12:46:39 +0200

> [PATCH] poll: Avoid extra wakeups in select/poll

Looks great to me:

Acked-by: David S. Miller <davem@davemloft.net>

But this has to go through something other than the
networking tree, of course :-)
