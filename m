From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [AX25] zero length frame filtering in AX25
Date: Sat, 21 Mar 2009 13:34:01 -0700 (PDT)
Message-ID: <20090321.133401.05623806.davem@davemloft.net>
References: <1237486695.30285.17.camel@f6bvp-11>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f6bvp@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55801
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752605AbZCUUeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 16:34:14 -0400
In-Reply-To: <1237486695.30285.17.camel@f6bvp-11>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: bernard pidoux <f6bvp@free.fr>
Date: Thu, 19 Mar 2009 19:18:15 +0100

> In previous commit 244f46ae6e9e18f6fc0be7d1f49febde4762c34b
> was introduced a zero length frame filter for ROSE protocole.
> This patch has the same purpose at AX25 frame level for the same
> reason. Empty frames have no meaning in AX25 protocole.
> 
> Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>

Applied.
