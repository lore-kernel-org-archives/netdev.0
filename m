From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] bridge: netlink: complete port attribute
 support
Date: Wed, 07 Oct 2015 04:50:04 -0700 (PDT)
Message-ID: <20151007.045004.1703152532685913386.davem@davemloft.net>
References: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798AbbJGLeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 07:34:20 -0400
In-Reply-To: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Tue,  6 Oct 2015 14:11:54 +0200

> This is the second set that completes the bridge port's netlink support and
> makes everything from sysfs available via netlink. I've used sysfs as a
> guide of what and how to set again. I've tested setting/getting every
> option and also this time tested enabling KASAN. Again there're a few long
> line warnings about the ifla attribute names in br_port_info_size() but
> as the previous set - it's good to know what's been accounted for.

Series applied, thanks Nik.
