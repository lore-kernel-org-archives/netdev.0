From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 6/6][IPV6][NETNS]: Display per-net info in
 sockstat6 file.
Date: Mon, 31 Mar 2008 20:19:25 -0700 (PDT)
Message-ID: <20080331.201925.06507066.davem@davemloft.net>
References: <47F0D6F1.7000105@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47824
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753475AbYDADTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 23:19:25 -0400
In-Reply-To: <47F0D6F1.7000105@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 31 Mar 2008 16:20:01 +0400

> Do with the sockstat6 file what we've already done for the sockstat. 
> Same good side effect - ipv6 reassembling stats are now shown per-net.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
