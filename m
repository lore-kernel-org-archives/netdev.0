From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: Move VRF table lookup to inlined function
Date: Mon, 17 Aug 2015 15:59:07 -0700 (PDT)
Message-ID: <20150817.155907.1747879082024033502.davem@davemloft.net>
References: <1439766807-3821-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36834 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbbHQW7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 18:59:08 -0400
In-Reply-To: <1439766807-3821-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun, 16 Aug 2015 17:13:27 -0600

> Table lookup compiles out when VRF is not enabled.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks.
