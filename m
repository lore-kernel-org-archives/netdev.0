From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2][INET]: Uninline the __inet_inherit_port call.
Date: Thu, 17 Apr 2008 23:18:27 -0700 (PDT)
Message-ID: <20080417.231827.28943441.davem@davemloft.net>
References: <4807747E.3020109@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@redhat.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56020
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753681AbYDRGS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 02:18:28 -0400
In-Reply-To: <4807747E.3020109@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 17 Apr 2008 20:02:06 +0400

> This deblats ~200 bytes when ipv6 and dccp are 'y'.
> 
> Besides, this will ease compilation issues for patches
> I'm working on to make inet hash tables more scalable 
> wrt net namespaces.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Also applied, thanks Pavel.
