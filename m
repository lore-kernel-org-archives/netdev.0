From: David Miller <davem@davemloft.net>
Subject: Re: net/socket.c: removed duplicated include
Date: Sat, 26 Jul 2008 17:52:24 -0700 (PDT)
Message-ID: <20080726.175224.154720381.davem@davemloft.net>
References: <20080726204541.AF61.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: weiyi.huang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48139
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756770AbYG0AwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 20:52:24 -0400
In-Reply-To: <20080726204541.AF61.WEIYI.HUANG@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huang Weiyi <weiyi.huang@gmail.com>
Date: Sat, 26 Jul 2008 20:56:09 +0800

> Removed duplicated include <linux/thread_info.h> in 
> net/socket.c.
> 
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

linux/thread_info.h is not included in net/socket.c in any
current tree I have access to.
