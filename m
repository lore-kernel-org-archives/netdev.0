From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v1.0] af_packet: don't emit packet on orig fanout
 group
Date: Thu, 16 Aug 2012 14:52:53 -0700 (PDT)
Message-ID: <20120816.145253.939105041613744695.davem@davemloft.net>
References: <1344262918.8024.41.camel@tiger.regit.org>
	<1345131890-15991-1-git-send-email-eric@regit.org>
	<20120816.145200.694410419765575459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric@regit.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab2HPVwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 17:52:53 -0400
In-Reply-To: <20120816.145200.694410419765575459.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


BTW, please also give "Aleksandr Kotov <a1k@mail.ru>" credit for
reporting this problem recently with a Reported-by tag, thanks.
