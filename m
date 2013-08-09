From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: sctp: convert sctp_checksum_disable
 module param into sctp sysctl
Date: Fri, 09 Aug 2013 11:33:20 -0700 (PDT)
Message-ID: <20130809.113320.681399334989952629.davem@davemloft.net>
References: <1375816693-7697-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49858 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968081Ab3HISdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 14:33:21 -0400
In-Reply-To: <1375816693-7697-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue,  6 Aug 2013 21:18:12 +0200

> Get rid of the last module parameter for SCTP and make this
> configurable via sysctl for SCTP like all the rest of SCTP's
> configuration knobs.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
