From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next] Open vSwitch
Date: Wed, 17 Apr 2013 13:31:24 -0400 (EDT)
Message-ID: <20130417.133124.226399047678410550.davem@davemloft.net>
References: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272Ab3DQRb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 13:31:26 -0400
In-Reply-To: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Tue, 16 Apr 2013 14:00:09 -0700

> A number of improvements for net-next/3.10.
> 
> Highlights include:
>  * Properly exposing linux/openvswitch.h to userspace after the uapi changes.
>  * Simplification of locking. It immediately makes things simpler to reason about and avoids holding RTNL mutex for longer than necessary. In the near future it will also enable tunnel registration and more fine-grained locking.
>  * Miscellaneous cleanups and simplifications.

Pulled, but please don't make your email look so silly with those 500
character long lines, make them not exceed 80 columns.

Thanks.
