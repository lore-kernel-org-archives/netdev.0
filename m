From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atarilance: timeout ignored in lance_open()
Date: Sun, 03 Jan 2010 21:43:19 -0800 (PST)
Message-ID: <20100103.214319.240976218.davem@davemloft.net>
References: <4B376074.2060305@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51820
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753035Ab0ADFnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:43:15 -0500
In-Reply-To: <4B376074.2060305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 27 Dec 2009 14:26:12 +0100

> With `while (--i > 0)' i reaches 0 after the loop, so upon timeout the
> error was not issued.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
