From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Add support for fill_slave_info to VRF
 device
Date: Sun, 07 Feb 2016 14:03:48 -0500 (EST)
Message-ID: <20160207.140348.804427694434362306.davem@davemloft.net>
References: <1454427826-6444-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754121AbcBGTDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 14:03:50 -0500
In-Reply-To: <1454427826-6444-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue,  2 Feb 2016 07:43:45 -0800

> Allows userspace to have direct access to VRF table association
> versus looking up master device and its table.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
