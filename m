From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] X.25 remove bkl in connect
Date: Tue, 14 Sep 2010 20:40:54 -0700 (PDT)
Message-ID: <20100914.204054.189709120.davem@davemloft.net>
References: <1284507123.1742.57.camel@jaunty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37273
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753161Ab0IODkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 23:40:36 -0400
In-Reply-To: <1284507123.1742.57.camel@jaunty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Wed, 15 Sep 2010 09:32:03 +1000

> Connect already has socket locking.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied.
