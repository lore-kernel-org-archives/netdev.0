From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/18] driver: isdn: hisax: remove cast for
 kmalloc/kzalloc return value
Date: Tue, 12 Mar 2013 11:41:40 -0400 (EDT)
Message-ID: <20130312.114140.6363374467308391.davem@davemloft.net>
References: <513EB23D.7020303@cn.fujitsu.com>
	<513EBA05.2040908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: zhangyanfei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932319Ab3CLPl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 11:41:29 -0400
In-Reply-To: <513EBA05.2040908@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Date: Tue, 12 Mar 2013 13:15:49 +0800

> remove cast for kmalloc/kzalloc return value.
> 
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Applied.
