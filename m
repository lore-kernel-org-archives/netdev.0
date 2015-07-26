From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] tipc: clean up socket message reception
Date: Sun, 26 Jul 2015 16:32:07 -0700 (PDT)
Message-ID: <20150726.163207.1427120102795138718.davem@davemloft.net>
References: <1437574280-12485-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092AbbGZXcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 19:32:08 -0400
In-Reply-To: <1437574280-12485-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 22 Jul 2015 10:11:17 -0400

> Despite recent improvements the message reception code in socket.c is
> perceived as obscure and hard to follow, especially regarding the logics
> for message rejection. With the commits in this series we try to remedy
> this situation.

Series applied, thanks Jon.
