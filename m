From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/4] net: kill unused macros from head file
Date: Thu, 02 Dec 2010 13:28:17 -0800 (PST)
Message-ID: <20101202.132817.242141787.davem@davemloft.net>
References: <4CF71AFD.6020409@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45245
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752971Ab0LBV1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 16:27:51 -0500
In-Reply-To: <4CF71AFD.6020409@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Thu, 02 Dec 2010 12:05:17 +0800

> These macros have been defined for several years since v2.6.12-rc2（tracing by git）,
> but never be used. So remove them.
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied.
