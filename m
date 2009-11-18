From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/16] drivers/net/can: remove exceptional & on function
 name
Date: Wed, 18 Nov 2009 10:48:57 -0800 (PST)
Message-ID: <20091118.104857.200195245.davem@davemloft.net>
References: <Pine.LNX.4.64.0911181920250.20943@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	netdev@vger.kernel.org, arnd@arndb.de, joe@perches.com,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58099
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755594AbZKRSsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 13:48:41 -0500
In-Reply-To: <Pine.LNX.4.64.0911181920250.20943@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Wed, 18 Nov 2009 19:20:44 +0100 (CET)

> In this file, function names are otherwise used as pointers without &.
...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
