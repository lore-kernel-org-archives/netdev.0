From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable 3.4 v2 1/2] ipv4: move route garbage collector
 to work queue
Date: Tue, 19 Aug 2014 13:34:22 -0700 (PDT)
Message-ID: <20140819.133422.1451297160651259753.davem@davemloft.net>
References: <547688b69ee9a258cc04e4dad17a90ca6ab182d0.1408045325.git.mleitner@redhat.com>
	<53F3B436.8050407@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbaHSUeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 16:34:12 -0400
In-Reply-To: <53F3B436.8050407@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Tue, 19 Aug 2014 17:31:50 -0300

> Sorry to bother you but WDYT, is this patchset more appropriate?

Yes it is and it's queued up in patchwork for -stable.
