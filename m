From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [IPV4] Remove declaration of unimplemented
 method and remove unused definition from include/net/ip_vs.h
Date: Tue, 01 Jan 2008 21:17:29 -0800 (PST)
Message-ID: <20080101.211729.226664468.davem@davemloft.net>
References: <eb3ff54b0801010119u49e2831eyfdaa001637fb8af0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43484
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751256AbYABFRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 00:17:30 -0500
In-Reply-To: <eb3ff54b0801010119u49e2831eyfdaa001637fb8af0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Tue, 1 Jan 2008 11:19:49 +0200

> In include/net/ip_vs.h:
> - The ip_vs_secure_tcp_set() method is not implemented anywhere.
> - IP_VS_APP_TYPE_FTP is an unused definition.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied.
