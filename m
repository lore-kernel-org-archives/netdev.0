From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/7] net: Export inet_offloads and
 inet6_offloads
Date: Mon, 15 Sep 2014 14:21:47 -0400 (EDT)
Message-ID: <20140915.142147.1377671205197098996.davem@davemloft.net>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
	<1410750483-3236-2-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370AbaIOSVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 14:21:50 -0400
In-Reply-To: <1410750483-3236-2-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 14 Sep 2014 20:07:57 -0700

> Want to be able to call this in foo-over-udp offloads, etc.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

I don't think inet{,6}_offloads are symbols you can "call" :-)
