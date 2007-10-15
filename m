From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] Consolidate the xxx_frag_kill
Date: Mon, 15 Oct 2007 02:37:31 -0700 (PDT)
Message-ID: <20071015.023731.34501178.davem@davemloft.net>
References: <470F6EAE.60308@openvz.org>
	<470F72CB.6010109@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53560
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754902AbXJOJh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:37:26 -0400
In-Reply-To: <470F72CB.6010109@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 12 Oct 2007 17:12:43 +0400

> Since now all the xxx_frag_kill functions now work
> with the generic inet_frag_queue data type, this can
> be moved into a common place.
> 
> The xxx_unlink() code is moved as well.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
