From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] xen-netfront: add support for IPv6 offloads
Date: Thu, 16 Jan 2014 16:23:55 -0800 (PST)
Message-ID: <20140116.162355.2015643029877352943.davem@davemloft.net>
References: <1389807033-11105-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55421 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbaAQAX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 19:23:56 -0500
In-Reply-To: <1389807033-11105-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Wed, 15 Jan 2014 17:30:33 +0000

> This patch adds support for IPv6 checksum offload and GSO when those
> features are available in the backend.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

Applied.
