From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5 v2] net: Refactor inetpeer cache and add
 support for VRFs
Date: Fri, 28 Aug 2015 13:32:54 -0700 (PDT)
Message-ID: <20150828.133254.2087014380836516026.davem@davemloft.net>
References: <1440716823-19568-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbbH1Ucz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 16:32:55 -0400
In-Reply-To: <1440716823-19568-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 27 Aug 2015 16:06:58 -0700

> Per Dave's comment on the version 1 patch adding VRF support to inetpeer
> cache by explicitly making the address + index a key. Refactored the
> inetpeer code in the process; mostly impacts the use by tcp_metrics.

Series applied, thanks.
