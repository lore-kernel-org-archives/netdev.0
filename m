From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Add tos to validate source tracepoint
Date: Mon, 31 Aug 2015 12:42:17 -0700 (PDT)
Message-ID: <20150831.124217.1711460309548188212.davem@davemloft.net>
References: <1441036632-26203-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309AbbHaTmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 15:42:18 -0400
In-Reply-To: <1441036632-26203-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 31 Aug 2015 09:57:12 -0600

> TOS is another key aspect of the lookup passed to fib_validate_source.
> Add it to the tracepoint.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
