From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net: minor cleanup to net_namespace.c."
Date: Sun, 12 Jun 2011 04:29:11 -0700 (PDT)
Message-ID: <20110612.042911.1713846819610012420.davem@davemloft.net>
References: <20110612110950.GA11321@p183.telecom.by>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rlandley@parallels.com, jpirko@redhat.com
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664Ab1FLLaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 07:30:08 -0400
In-Reply-To: <20110612110950.GA11321@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 12 Jun 2011 14:09:50 +0300

> * C/R and other out-of-tree code uses or will use it,

Submit this with the out-of-tree code that needs it,
we never cater to external bits like this.
