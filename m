From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]drivers/net/eql.c:fix a dev leakage
Date: Wed, 08 Apr 2009 15:56:42 -0700 (PDT)
Message-ID: <20090408.155642.18890012.davem@davemloft.net>
References: <49DC14B3.9020308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33818
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754565AbZDHW4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 18:56:52 -0400
In-Reply-To: <49DC14B3.9020308@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Wed, 08 Apr 2009 11:06:27 +0800

> After dev_get_by_name(),we should follow a dev_put().build test only.
> 
> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

Applied, thanks.
