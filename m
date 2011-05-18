From: David Miller <davem@davemloft.net>
Subject: Re: PATCH] SCTP: fix race between sctp_bind_addr_free() and
 sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 15:58:18 -0400 (EDT)
Message-ID: <20110518.155818.2171224302265138837.davem@davemloft.net>
References: <BANLkTimWpmFj1gx=XvvoXFVxL9q927iWfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladislav.yasevich@hp.com,
	eric.dumazet@gmail.com
To: difrost.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36451 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986Ab1ERT6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 15:58:25 -0400
In-Reply-To: <BANLkTimWpmFj1gx=XvvoXFVxL9q927iWfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacek Luczak <difrost.kernel@gmail.com>
Date: Wed, 18 May 2011 16:36:32 +0200

> @@ -140,14 +140,12 @@ void sctp_bind_addr_init(struct sctp_bind_addr
> *bp, __u16 port)

As Eric stated, you need to fix your mailer to not corrupt your patch.
GMAIL users can, and do, submit patches properly, unmangled.  Heck,
even Thunderbird users can it.

Please follow the directions in Documentation/email-clients.txt to
get your mailer in a state where it won't mangle your patch postings.

Thanks.
