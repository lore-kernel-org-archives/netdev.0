From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] Cut off the queue_mapping field from sk_buff
Date: Sun, 21 Oct 2007 17:02:40 -0700 (PDT)
Message-ID: <20071021.170240.26950367.davem@davemloft.net>
References: <471871E5.7060900@openvz.org>
	<47187364.9050102@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750839AbXJVAC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 20:02:27 -0400
In-Reply-To: <47187364.9050102@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 19 Oct 2007 13:05:40 +0400

> Just hide it behind the #ifdef, because nobody wants
> it now.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Also applied, thanks!
