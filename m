From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 48/53] netns PF_KEY: part 2
Date: Tue, 25 Nov 2008 17:58:38 -0800 (PST)
Message-ID: <20081125.175838.202224371.davem@davemloft.net>
References: <1227634045-27534-46-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-47-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-48-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57384
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752642AbYKZB6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 20:58:39 -0500
In-Reply-To: <1227634045-27534-48-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 25 Nov 2008 20:27:20 +0300

> * interaction with userspace -- take netns from userspace socket.
> * in ->notify hook take netns either from SA or explicitly passed --
> 	we don't know if SA/SPD flush is coming.
> * stub policy migration with init_net for now.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
