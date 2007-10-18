From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix return type for snmp6_free_dev()
Date: Wed, 17 Oct 2007 21:23:51 -0700 (PDT)
Message-ID: <20071017.212351.55722715.davem@davemloft.net>
References: <4715E3F7.7050506@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36729
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751255AbXJREXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:23:54 -0400
In-Reply-To: <4715E3F7.7050506@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 17 Oct 2007 14:29:11 +0400

> This call is essentially void.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
