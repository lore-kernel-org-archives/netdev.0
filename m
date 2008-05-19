From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/6][FRAGS]: Register some ctls at read-only
 root.
Date: Mon, 19 May 2008 13:54:21 -0700 (PDT)
Message-ID: <20080519.135421.70891254.davem@davemloft.net>
References: <4831A1D6.4090503@openvz.org>
	<4831A4F7.8070108@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56352
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756865AbYESUy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 16:54:26 -0400
In-Reply-To: <4831A4F7.8070108@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 19 May 2008 20:04:07 +0400

> Parts of fragments-related sysctls are read-only, but this is
> done by cloning all the tables and dropping write-bits from
> mode. Do the same but with read-only root.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
