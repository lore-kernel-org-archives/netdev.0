From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] net: Fixes to remote checksum offload and
 CHECKSUM_PARTIAL
Date: Wed, 11 Feb 2015 15:18:09 -0800 (PST)
Message-ID: <20150211.151809.2198174178164809226.davem@davemloft.net>
References: <1423614633-25042-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530AbbBKXLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 18:11:14 -0500
In-Reply-To: <1423614633-25042-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 10 Feb 2015 16:30:26 -0800

> This patch set fixes a correctness problem with remote checksum
> offload, clarifies the meaning of CHECKSUM_PARTIAL, and allows
> remote checksum offload to set CHECKSUM_PARTIAL instead of
> calling csum_partial and modifying the checksum.

Series applied, thanks Tom.
