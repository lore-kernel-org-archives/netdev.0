From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] eepro: Read buffer overflow
Date: Sun, 26 Jul 2009 19:01:54 -0700 (PDT)
Message-ID: <20090726.190154.69343369.davem@davemloft.net>
References: <4A6B89FB.8020103@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44682
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755700AbZG0CBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 22:01:48 -0400
In-Reply-To: <4A6B89FB.8020103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 26 Jul 2009 00:40:59 +0200

> io[i] is read before the bounds check on i, order should be reversed
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
