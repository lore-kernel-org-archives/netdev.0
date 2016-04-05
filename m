From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sctp: use list_* in sctp_list_dequeue
Date: Tue, 05 Apr 2016 15:44:23 -0400 (EDT)
Message-ID: <20160405.154423.1746284768680802731.davem@davemloft.net>
References: <729a27385f91aacaee46ecfa6f37f084f2843b9c.1459530791.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbcDETo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 15:44:26 -0400
In-Reply-To: <729a27385f91aacaee46ecfa6f37f084f2843b9c.1459530791.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri,  1 Apr 2016 14:30:32 -0300

> Use list_* helpers in sctp_list_dequeue, more readable.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
> v2: patch rechecked

Also applied, thanks.
