From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sctp: prevent checksum.h from double
 inclusion
Date: Tue, 02 Jul 2013 00:24:20 -0700 (PDT)
Message-ID: <20130702.002420.1956477333608952976.davem@davemloft.net>
References: <1372695036-10914-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932219Ab3GBHYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 03:24:21 -0400
In-Reply-To: <1372695036-10914-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon,  1 Jul 2013 18:10:36 +0200

> The header file checksum.h is missing proper defines that prevents
> it from double inclusion.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
