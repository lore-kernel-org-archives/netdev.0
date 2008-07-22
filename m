From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make get_proc_net() static
Date: Tue, 22 Jul 2008 14:19:28 -0700 (PDT)
Message-ID: <20080722.141928.100604401.davem@davemloft.net>
References: <20080722172033.GQ14846@cs181140183.pp.htv.fi>
	<4886313C.3000200@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38629
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757696AbYGVVT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:19:28 -0400
In-Reply-To: <4886313C.3000200@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 22 Jul 2008 23:13:00 +0400

> Adrian Bunk wrote:
> > get_proc_net() can now become static.
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> Acked-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
