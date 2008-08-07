From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix kernel panic when calling tcp_v(4/6)_md5_do_lookup
Date: Wed, 06 Aug 2008 23:51:04 -0700 (PDT)
Message-ID: <20080806.235104.131924535.davem@davemloft.net>
References: <20080806.224411.210555962.davem@davemloft.net>
	<20080806.224708.172981191.davem@davemloft.net>
	<489A99D6.4080809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: guijianfeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46026
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750994AbYHGGvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 02:51:04 -0400
In-Reply-To: <489A99D6.4080809@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Date: Thu, 07 Aug 2008 14:44:38 +0800

> If the following packet flow happen, kernel will panic.

Applied, let's see if this one build properly :-)
