From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] PF_PACKET timestamping updates
Date: Thu, 25 Apr 2013 01:35:17 -0400 (EDT)
Message-ID: <20130425.013517.27784665767438846.davem@davemloft.net>
References: <1366713572-11978-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, Paul.Chavent@onera.fr,
	richardcochran@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab3DYFfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:35:18 -0400
In-Reply-To: <1366713572-11978-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 23 Apr 2013 12:39:27 +0200

> This is a joint effort with Willem to bring optional i) tx hw/sw
> timestamping into PF_PACKET, that was reported by Paul Chavent,
> and ii) to expose the type of timestamp to the user, which is in
> the current situation not possible to distinguish with the RX_RING
> and TX_RING API (but distinguishable through the normal timestamping
> API), reported by Richard Cochran. This set is based on top of
> ``packet: account statistics only in tpacket_stats_u''. Related
> discussion can be found in: http://patchwork.ozlabs.org/patch/238125/

Series applied, thanks.
