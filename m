From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 28/31] net: Make static
Date: Wed, 10 Dec 2008 15:18:55 -0800 (PST)
Message-ID: <20081210.151855.191710508.davem@davemloft.net>
References: <493EA286.7080500@gmail.com>
	<493EEF28.1040007@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40147
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754554AbYLJXSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 18:18:54 -0500
In-Reply-To: <493EEF28.1040007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Tue, 09 Dec 2008 23:20:24 +0100

> Sparse asked whether these could be static.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

net-next-2.6 already had some of these fixed already, so
I kicked those parts out and applied the rest of your
patch.

Thanks!
