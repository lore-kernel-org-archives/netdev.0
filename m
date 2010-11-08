From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] classifier: report statistics for basic classifier
Date: Mon, 08 Nov 2010 12:18:40 -0800 (PST)
Message-ID: <20101108.121840.104064201.davem@davemloft.net>
References: <20101104174704.573c52e4@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43044
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753179Ab0KHUSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 15:18:15 -0500
In-Reply-To: <20101104174704.573c52e4@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 4 Nov 2010 17:47:04 -0400

> The basic classifier keeps statistics but does not report it to user space.
> This showed up when using basic classifier (with police) as a default catch
> all on ingress; no statistics were reported.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
