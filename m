From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bridge: use DEVICE_ATTR_xx macros
Date: Mon, 06 Jan 2014 16:41:26 -0500 (EST)
Message-ID: <20140106.164126.1436204419132200005.davem@davemloft.net>
References: <20140106190044.10912.47228.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	curt@cumulusnetworks.com, shm@cumulusnetworks.com
To: sfeldma@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755511AbaAFVl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:41:28 -0500
In-Reply-To: <20140106190044.10912.47228.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@cumulusnetworks.com>
Date: Mon, 06 Jan 2014 11:00:44 -0800

> Use DEVICE_ATTR_RO/RW macros to simplify bridge sysfs attribute definitions.
> 
> Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>

Applied to net-next, thanks.
