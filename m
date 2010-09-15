From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] X.25 remove bkl in bind
Date: Tue, 14 Sep 2010 20:40:24 -0700 (PDT)
Message-ID: <20100914.204024.71110909.davem@davemloft.net>
References: <1284507098.1742.55.camel@jaunty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37265
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753186Ab0IODkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 23:40:05 -0400
In-Reply-To: <1284507098.1742.55.camel@jaunty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Wed, 15 Sep 2010 09:31:38 +1000

> Accept updates socket values in 3 lines so wrapped with lock_sock.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied.
