From: David Miller <davem@davemloft.net>
Subject: Re: [patch] fix error handle in ip_mc_add_src()
Date: Mon, 21 Nov 2011 13:30:23 -0500 (EST)
Message-ID: <20111121.133023.851983095187929096.davem@davemloft.net>
References: <1321887946.14281.27.camel@barry.pixelworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mypopydev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748Ab1KUSa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 13:30:26 -0500
In-Reply-To: <1321887946.14281.27.camel@barry.pixelworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jun Zhao <mypopydev@gmail.com>
Date: Mon, 21 Nov 2011 23:05:46 +0800

> When add sources to interface failure, need to roll back the sfcount[MODE] 
> to before state. We need to match it corresponding. 

You need to private a proper "Signed-off-by: " tag with your patch, please
read Documentation/SubmittingPatches.

DO not just reply to this email with the signoff tag, instead make a new,
fresh, clean posting of your patch with the necessary tag.
