From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2 2/2] macvtap: do not zerocopy if iov needs more
 pages than MAX_SKB_FRAGS
Date: Tue, 30 Jul 2013 12:55:42 -0700 (PDT)
Message-ID: <20130730.125542.2060050812919169911.davem@davemloft.net>
References: <1374116116-43844-2-git-send-email-jasowang@redhat.com>
	<20130719050351.GB8537@redhat.com>
	<20130730114125.GB22218@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40993 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757074Ab3G3Tzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 15:55:43 -0400
In-Reply-To: <20130730114125.GB22218@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 30 Jul 2013 14:41:25 +0300

> Was this patch dropped?

Nope, it's commit ece793fcfc417b3925844be88a6a6dc82ae8f7c6

> Any objections to merging it for 3.11 and stable?

No objection, queued up for -stable.
