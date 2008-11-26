From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 42/53] netns xfrm: pass netns with KM notifications
Date: Tue, 25 Nov 2008 17:50:42 -0800 (PST)
Message-ID: <20081125.175042.44529592.davem@davemloft.net>
References: <1227634045-27534-40-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-41-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-42-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35392
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752141AbYKZBun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 20:50:43 -0500
In-Reply-To: <1227634045-27534-42-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 25 Nov 2008 20:27:14 +0300

> SA and SPD flush are executed with NULL SA and SPD respectively, for
> these cases pass netns explicitly from userspace socket.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
