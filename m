From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] vrf: a few simplifications and cleanups
Date: Tue, 18 Aug 2015 20:17:12 -0700 (PDT)
Message-ID: <20150818.201712.2226787285967166778.davem@davemloft.net>
References: <1439918884-13681-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	shm@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbbHSDRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 23:17:14 -0400
In-Reply-To: <1439918884-13681-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Tue, 18 Aug 2015 20:28:00 +0300

> These patches remove some unnecessary checks (patches 3, 4), unnecessary
> num_slaves member and refcnt manipulations which are already done by the
> upper functions.

Series applied, thanks.
