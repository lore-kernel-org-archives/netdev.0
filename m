From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] xfrm: Fix null pointer dereference when decoding
 sessions
Date: Thu, 05 Dec 2013 16:35:33 -0500 (EST)
Message-ID: <20131205.163533.1503503077750560734.davem@davemloft.net>
References: <529AB8E9.30004@universe-factory.net>
	<20131201.203506.1790384137281236147.davem@davemloft.net>
	<20131203095645.GS31491@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschiffer@universe-factory.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20131203095645.GS31491@secunet.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 3 Dec 2013 10:56:45 +0100

> It apparently did not make it into v3.12.2 and it is not in the v3.12.3
> review included. So I wonder if I need to do anything additional to
> get it included. It is the first time that I did a stable submission
> myself.

I'm taking care of this myself now, don't worry any more about it.

Thanks.
