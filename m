From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: call ql_core_dump() only if dump memory was
 allocated.
Date: Fri, 20 Sep 2013 12:02:01 -0400 (EDT)
Message-ID: <20130920.120201.1305554403409938708.davem@davemloft.net>
References: <1379691031-28666-1-git-send-email-malahal@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: malahal@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147Ab3ITQCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 12:02:03 -0400
In-Reply-To: <1379691031-28666-1-git-send-email-malahal@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Malahal Naineni <malahal@us.ibm.com>
Date: Fri, 20 Sep 2013 10:30:31 -0500

> Also changed a log message to indicate that memory was not allocated
> instead of memory not available!

This change is not submitted properly, in particular it is missing
a signoff.
