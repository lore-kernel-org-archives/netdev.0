From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Phonet: include generic link-layer header size in
 MAX_PHONET_HEADER
Date: Sun, 26 Oct 2008 23:06:51 -0700 (PDT)
Message-ID: <20081026.230651.251009215.davem@davemloft.net>
References: <1224860139-23097-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57230
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751095AbYJ0GHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 02:07:13 -0400
In-Reply-To: <1224860139-23097-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Fri, 24 Oct 2008 17:55:38 +0300

> This fixes an OOPS in hard_header if a Phonet address is assigned to
> a non-Phonet network interface.
> 
> Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.
