From: David Miller <davem@davemloft.net>
Subject: Re: Kernel oops when clearing bgp neighbor info with TCP MD5SUM
 enabled
Date: Thu, 08 Oct 2009 15:54:29 -0700 (PDT)
Message-ID: <20091008.155429.02850661.davem@davemloft.net>
References: <Pine.LNX.4.64.0910081514050.18315@sleet.zeugmasystems.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: asinha@zeugmasystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45546
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754491AbZJHWye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 18:54:34 -0400
In-Reply-To: <Pine.LNX.4.64.0910081514050.18315@sleet.zeugmasystems.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Sinha <asinha@zeugmasystems.com>
Date: Thu, 8 Oct 2009 15:19:48 -0700 (PDT)

> We are noticing a kernel OOPS on 2.6.26 kernel when we issue the command
> "clear ip bgp <bgp-peer-ip>" on Quagga BGP routing software.

You will need to update your kernel, there have been many TCP
MD5 bug fixes since 2.6.26
