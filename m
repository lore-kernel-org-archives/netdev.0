From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25-rc] [IPV6] SYSCTL: Fix possible memory leakage
 in error path.
Date: Wed, 27 Feb 2008 12:06:56 -0800 (PST)
Message-ID: <20080227.120656.129224449.davem@davemloft.net>
References: <20080228.002014.05421460.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59600
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757291AbYB0UG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 15:06:57 -0500
In-Reply-To: <20080228.002014.05421460.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 28 Feb 2008 00:20:14 +0900 (JST)

> In error path, we do need to free memory just allocated.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Patch applied, thank you.
