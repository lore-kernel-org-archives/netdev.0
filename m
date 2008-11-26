From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/53] netns xfrm: per-netns xfrm_state_hmask
Date: Tue, 25 Nov 2008 17:18:18 -0800 (PST)
Message-ID: <20081125.171818.140962020.davem@davemloft.net>
References: <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-7-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-8-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752238AbYKZBST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 20:18:19 -0500
In-Reply-To: <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 25 Nov 2008 20:26:40 +0300

> Since hashtables are per-netns, they can be independently resized.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
