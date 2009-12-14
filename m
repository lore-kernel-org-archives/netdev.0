From: David Miller <davem@davemloft.net>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Mon, 14 Dec 2009 14:35:22 -0800 (PST)
Message-ID: <20091214.143522.102450157.davem@davemloft.net>
References: <20091214.111105.224947761.davem@davemloft.net>
	<20091214.111638.165984790.davem@davemloft.net>
	<4B2690B4.3030604@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.dykstra1@gmail.com, lists@nerdbynature.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34952
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750848AbZLNWfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 17:35:21 -0500
In-Reply-To: <4B2690B4.3030604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Dec 2009 20:23:32 +0100

> If you disable syncookies, I presume you dont have warnings ?

It happens even with syncookies disabled, hmmm...
