From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bonding: extend the 3ad exported
 attributes
Date: Mon, 15 Jun 2015 16:40:41 -0700 (PDT)
Message-ID: <20150615.164041.1369196373154810989.davem@davemloft.net>
References: <1434288995-25457-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@cumulusnetworks.com,
	j.vosburgh@gmail.com, vfalico@gmail.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42578 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbbFOXkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 19:40:42 -0400
In-Reply-To: <1434288995-25457-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Sun, 14 Jun 2015 16:36:33 +0300

> These are two small patches that export actor_oper_port_state and
> partner_oper_port_state via netlink and sysfs, until now they were only
> exported via bond's proc entry. If this set gets accepted I have an iproute2
> patch prepared that will export them with which I tested these changes.

Series applied, thank you.
