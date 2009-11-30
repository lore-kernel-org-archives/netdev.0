From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: restore mac addr in rtl8169_remove_one and
 rtl_shutdown
Date: Sun, 29 Nov 2009 23:13:14 -0800 (PST)
Message-ID: <20091129.231314.211493103.davem@davemloft.net>
References: <1259087166-14558-1-git-send-email-ivecera@redhat.com>
	<20091129.002157.14823135.davem@davemloft.net>
	<20091129143902.GA17831@zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, netdev@vger.kernel.org
To: romieu@zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54403
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751064AbZK3HNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 02:13:08 -0500
In-Reply-To: <20091129143902.GA17831@zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: François romieu <romieu@zoreil.com>
Date: Sun, 29 Nov 2009 15:39:02 +0100

> The Sun, Nov 29, 2009 at 12:21:57AM -0800, David Miller wrote :
> [...]
>> Francois, any comments?
> 
> It is low risk and manageable. Go for it.

Ok, thanks for the review.
