From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/5] s390: qeth and iucv patches
Date: Mon, 21 Sep 2015 16:03:23 -0700 (PDT)
Message-ID: <20150921.160323.1783389736596859261.davem@davemloft.net>
References: <1442585212-58347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932817AbbIUXDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:03:24 -0400
In-Reply-To: <1442585212-58347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Fri, 18 Sep 2015 16:06:47 +0200

> here is version 2 of some s390 related qeth patches for net-next. The patch by
> Thomas Richter adds a new feature to the qeth layer2 code; the remaining
> patches are minor improvements.
> Version 2 of patch 4 uses the desired indentation in function declarations
> and definitions spanning multiple lines in almost all cases. Thomas run into a
> conflict with the maximum number of columns once. Thus you will still see one
> function definition using an earlier column before the opening paranthesis.

Series applied to net-next, thanks.
