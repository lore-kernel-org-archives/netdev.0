From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Fix duplicate #include headers
Date: Mon, 07 Apr 2014 13:19:02 -0400 (EDT)
Message-ID: <20140407.131902.31160920821686929.davem@davemloft.net>
References: <1396679341-23502-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162AbaDGRTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 13:19:04 -0400
In-Reply-To: <1396679341-23502-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Sat,  5 Apr 2014 00:28:59 -0600

> This tiny series fixes the same issue of duplicate #include headers.
> 
> Jean Sacren (2):
>   sxgbe: fix duplicate #include headers
>   mac802154: fix duplicate #include headers

Both applied, thanks.
