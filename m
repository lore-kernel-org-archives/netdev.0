From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] ip_gre: allow CSUM capable devices to
 handle packets
Date: Tue, 19 Feb 2013 00:53:30 -0500 (EST)
Message-ID: <20130219.005330.1274047573326974776.davem@davemloft.net>
References: <1361217053-16984-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754968Ab3BSFxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 00:53:31 -0500
In-Reply-To: <1361217053-16984-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Mon, 18 Feb 2013 21:50:52 +0200

> If device is not able to handle checksumming it will
> be handled in dev_xmit
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>

Applied.
