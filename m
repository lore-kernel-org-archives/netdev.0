From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] bridge: support sending rntl info when we
 set attributes through sysfs/ioctl
Date: Wed, 16 Mar 2016 23:35:05 -0400 (EDT)
Message-ID: <20160316.233505.1953107815126511729.davem@davemloft.net>
References: <cover.1458134414.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	nikolay@cumulusnetworks.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54174 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbcCQDfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 23:35:10 -0400
In-Reply-To: <cover.1458134414.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 16 Mar 2016 21:34:43 +0800

> This patchset is used to support sending rntl info to user in some places,
> and ensure that whenever those attributes change internally or from sysfs,
> that a netlink notification is sent out to listeners.

This is too late for net-next, please wait until after the merge window.

Thanks.
