From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix missing send up SCTP_SENDER_DRY_EVENT when
 subscribe it
Date: Sat, 02 Jul 2011 04:55:17 -0700 (PDT)
Message-ID: <20110702.045517.375409425542144540.davem@davemloft.net>
References: <4E0F6F20.5020505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Michael.Tuexen@lurchi.franken.de, seggelmann@fh-muenster.de
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470Ab1GBL4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2011 07:56:46 -0400
In-Reply-To: <4E0F6F20.5020505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sun, 03 Jul 2011 03:18:56 +0800

> @@ -2073,10 +2073,33 @@ static int
> sctp_setsockopt_disable_fragments(struct sock *sk,

Patch corrupted by your email client.
