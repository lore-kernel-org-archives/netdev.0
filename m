From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] sky2: Bug fixes
Date: Tue, 26 Mar 2013 12:57:50 -0400 (EDT)
Message-ID: <20130326.125750.2118131777063221688.davem@davemloft.net>
References: <6676087.yBMeFJ6grC@mlindner-lin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: mlindner@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996Ab3CZQ5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:57:53 -0400
In-Reply-To: <6676087.yBMeFJ6grC@mlindner-lin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mirko Lindner <mlindner@marvell.com>
Date: Tue, 26 Mar 2013 17:38:28 +0100

> Please find here 2 bug fixes related to the sky2 driver
> 
> These are both patches against net-next but should be
> applied to -stable as well.
> 
> Mirko Lindner (2):
>   Receive Overflows not counted
>   Threshold for Pause Packet is set wrong

Stephen, these look very straight-forward and correct, please
review.
