From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] decnet: avoid touching device refcount in
 dn_dev_by_index()
Date: Wed, 04 Nov 2009 10:59:46 -0800 (PST)
Message-ID: <20091104.105946.127572840.davem@davemloft.net>
References: <4AF1C4B2.6090802@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50846
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751406AbZKDS7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 13:59:21 -0500
In-Reply-To: <4AF1C4B2.6090802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Nov 2009 19:15:14 +0100

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
