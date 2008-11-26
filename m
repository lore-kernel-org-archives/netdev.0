From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 46/53] netns xfrm: flush SA/SPDs on netns stop
Date: Tue, 25 Nov 2008 17:57:50 -0800 (PST)
Message-ID: <20081125.175750.29667024.davem@davemloft.net>
References: <1227634045-27534-44-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-45-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-46-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39918
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752272AbYKZB5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 20:57:51 -0500
In-Reply-To: <1227634045-27534-46-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 25 Nov 2008 20:27:18 +0300

> SA/SPD doesn't pin netns (and it shouldn't), so get rid of them by hand.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
