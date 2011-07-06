From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] sctp: Enforce retransmission limit during shutdown
Date: Wed, 06 Jul 2011 00:24:14 -0700 (PDT)
Message-ID: <20110706.002414.386457642239523783.davem@davemloft.net>
References: <20110630084933.GA24074@canuck.infradead.org>
	<4E0C8368.5090502@hp.com>
	<20110704135019.GA801@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	yjwei@cn.fujitsu.com, sri@us.ibm.com, linux-sctp@vger.kernel.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568Ab1GFHZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 03:25:32 -0400
In-Reply-To: <20110704135019.GA801@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Vlad, SCTP folks, please review this patch.
