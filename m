From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] ipip: used time_before for comparing jiffies
Date: Tue, 24 Feb 2009 23:38:51 -0800 (PST)
Message-ID: <20090224.233851.180893280.davem@davemloft.net>
References: <49A3A7D3.8080508@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55483
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757897AbZBYHjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:39:10 -0500
In-Reply-To: <49A3A7D3.8080508@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 24 Feb 2009 15:54:59 +0800

> The functions time_before is more robust for comparing
> jiffies against other values.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
