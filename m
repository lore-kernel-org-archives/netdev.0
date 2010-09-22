From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] X.25 remove bkl in poll
Date: Wed, 22 Sep 2010 13:36:35 -0700 (PDT)
Message-ID: <20100922.133635.102560013.davem@davemloft.net>
References: <1285118685.28503.46.camel@jaunty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40907
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752362Ab0IVUgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 16:36:16 -0400
In-Reply-To: <1285118685.28503.46.camel@jaunty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Wed, 22 Sep 2010 11:24:45 +1000

> The x25_datagram_poll didn't add anything, removed it.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied.
