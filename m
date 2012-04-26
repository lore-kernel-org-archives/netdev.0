From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sock_diag_handler structs can be const
Date: Wed, 25 Apr 2012 20:47:39 -0400 (EDT)
Message-ID: <20120425.204739.357701276066555791.davem@davemloft.net>
References: <4F977BB3.5040201@gmail.com>
	<4F97EE11.2090408@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei88@gmail.com, netdev@vger.kernel.org, davidshan@tencent.com
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932716Ab2DZAsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 20:48:25 -0400
In-Reply-To: <4F97EE11.2090408@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Wed, 25 Apr 2012 16:29:05 +0400

> On 04/25/2012 08:21 AM, Shan Wei wrote:
>> From: Shan Wei <davidshan@tencent.com>
>> 
>> read only, so change it to const.
>> 
>> Signed-off-by: Shan Wei <davidshan@tencent.com>
> 
> Acked-by: Pavel Emelyanov <xemul@parallels.com>

Applied.
