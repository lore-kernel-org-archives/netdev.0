From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/6][NETNS]: Introduce sysctl root for
 read-only net sysctls.
Date: Mon, 19 May 2008 13:53:42 -0700 (PDT)
Message-ID: <20080519.135342.267694038.davem@davemloft.net>
References: <4831A1D6.4090503@openvz.org>
	<4831A24B.1080807@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56339
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752894AbYESUxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 16:53:46 -0400
In-Reply-To: <4831A24B.1080807@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 19 May 2008 19:52:43 +0400

> This one stores all ctl-heads in one list and restricts the
> permissions not give write access to non-init net namespaces.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
