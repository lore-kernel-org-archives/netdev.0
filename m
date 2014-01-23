From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/5] fix bonding slave info API (sysfs and
 netlink)
Date: Wed, 22 Jan 2014 21:58:22 -0800 (PST)
Message-ID: <20140122.215822.1124845121926313026.davem@davemloft.net>
References: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	nicolas.dichtel@6wind.com, john.r.fastabend@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932154AbaAWF6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 00:58:23 -0500
In-Reply-To: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 22 Jan 2014 09:05:52 +0100

> The main part of this patchset is the introduction of a generic way how
> to get/set info of slaves unsing rtnl_link_ops.

Series applied.
