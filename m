From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: really allow using GFP_KERNEL on
 sctp_packet_transmit
Date: Wed, 30 Mar 2016 15:42:21 -0400 (EDT)
Message-ID: <20160330.154221.1176908955449716860.davem@davemloft.net>
References: <1459258863-21351-1-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055AbcC3TmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 15:42:24 -0400
In-Reply-To: <1459258863-21351-1-git-send-email-marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Tue, 29 Mar 2016 10:41:03 -0300

> Somehow my patch for commit cea8768f333e ("sctp: allow
> sctp_transmit_packet and others to use gfp") missed two important
> chunks, which are now added.
> 
> Fixes: cea8768f333e ("sctp: allow sctp_transmit_packet and others to use gfp")
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
