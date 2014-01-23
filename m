From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/25] bonding: introduce new option API
Date: Wed, 22 Jan 2014 16:29:20 -0800 (PST)
Message-ID: <20140122.162920.2071700249223958135.davem@davemloft.net>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com, sfeldma@cumulusnetworks.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaAWA3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 19:29:23 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Wed, 22 Jan 2014 14:53:15 +0100

> This patchset's goal is to introduce a new option API which should be used
> to properly describe the bonding options with their mode dependcies and
> requirements. With this patchset applied we get centralized option
> manipulation, automatic RTNL acquire per option setting, automatic option
> range checking, mode dependcy checking and other various flags which are
> described in detail in patch 01's commit message and comments.

This looks great, all applied, thanks!
