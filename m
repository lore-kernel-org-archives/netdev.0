From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] crypto: gmac - Add RFC4543 wrapper for GCM
Date: Tue, 01 Dec 2009 15:51:41 -0800 (PST)
Message-ID: <20091201.155141.147973233.davem@davemloft.net>
References: <4B154918.7070008@strongswan.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: tobias@strongswan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44678
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754046AbZLAXvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 18:51:35 -0500
In-Reply-To: <4B154918.7070008@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Brunner <tobias@strongswan.org>
Date: Tue, 01 Dec 2009 17:49:28 +0100

> This patch adds the RFC4543 (GMAC) wrapper for GCM similar to the
> existing RFC4106 wrapper. The main differences between GCM and GMAC are
> the contents of the AAD and that the plaintext is empty for the latter.
> 
> Signed-off-by: Tobias Brunner <tobias@strongswan.org>

Herbert, you got this one?

Thanks.
