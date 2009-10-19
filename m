From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] IPsec: convert to ahash
Date: Sun, 18 Oct 2009 21:34:29 -0700 (PDT)
Message-ID: <20091018.213429.242479125.davem@davemloft.net>
References: <20091008084631.GJ15653@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750837AbZJSEeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 00:34:07 -0400
In-Reply-To: <20091008084631.GJ15653@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 8 Oct 2009 10:46:31 +0200

> This patchset converts the authentication header (ah4/ah6) IPsec protocol
> over to the new ahash interface. With this patchset IPsec is completely
> converted to ahash. The esp protocol is already converted to ahash by
> converting the authenc crypto algorithm.

All applied to net-next-2.6, thanks Steffen!
