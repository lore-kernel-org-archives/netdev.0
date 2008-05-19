From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/6][FRAGS]: Rename sysctl-related
 functions/variables.
Date: Mon, 19 May 2008 13:53:56 -0700 (PDT)
Message-ID: <20080519.135356.50390508.davem@davemloft.net>
References: <4831A1D6.4090503@openvz.org>
	<4831A3B0.80301@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56346
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757747AbYESUyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 16:54:01 -0400
In-Reply-To: <4831A3B0.80301@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 19 May 2008 19:58:40 +0400

> The fragments sysctls also contains some, that are to be
> visible, but read-only in net namespaces.
> 
> The naming in net/core/sysctl_net_core.c is - tables, that are
> to be registered in namespaces have a "ns" word in their names.
> So rename ones in ipv4/ip_fragment.c and ipv6/reassembly.c to
> fit this.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
