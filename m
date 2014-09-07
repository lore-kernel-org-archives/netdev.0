From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/5] bridge: implement rtnl_link options for
 getting and setting bridge options
Date: Sun, 07 Sep 2014 16:06:40 -0700 (PDT)
Message-ID: <20140907.160640.219047789264664028.davem@davemloft.net>
References: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56444 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309AbaIGXGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 19:06:41 -0400
In-Reply-To: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  5 Sep 2014 15:51:27 +0200

> So far, only sysfs is complete interface for getting and setting bridge
> options. This patchset follows-up on the similar bonding code and
> allows userspace to get/set bridge master/port options using Netlink
> IFLA_INFO_DATA/IFLA_INFO_SLAVE_DATA attr.

Stephen, please review this series, thanks.
