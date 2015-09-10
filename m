From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/2] xen-net{front,back}: respect user provided
 max_queues
Date: Thu, 10 Sep 2015 10:12:22 -0700 (PDT)
Message-ID: <20150910.101222.1194594282942480385.davem@davemloft.net>
References: <1441880338-4911-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbbIJRMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 13:12:23 -0400
In-Reply-To: <1441880338-4911-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Thu, 10 Sep 2015 11:18:56 +0100

> Wei Liu (2):
>   xen-netback: respect user provided max_queues
>   xen-netfront: respect user provided max_queues

This looks better, series applied, thanks.
