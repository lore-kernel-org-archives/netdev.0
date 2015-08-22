From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vrf: rename the framework to mrf
Date: Sat, 22 Aug 2015 10:47:21 -0700 (PDT)
Message-ID: <20150822.104721.739206355128347497.davem@davemloft.net>
References: <1440259820-7875-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	dsa@cumulusnetworks.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131AbbHVRr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2015 13:47:26 -0400
In-Reply-To: <1440259820-7875-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Sat, 22 Aug 2015 18:10:20 +0200

> This patch renames the recently added vrf driver. 'VRF' term is very
> generic and there is no clear definition of it.
> For example, someone may expect more isolation and uses network namespaces
> to implement VRF,

This is a rediculous argument.

Does someone using VRF on a Cisco box expect Linux namespaces to be used?

Sorry, this is not going to get applied.
