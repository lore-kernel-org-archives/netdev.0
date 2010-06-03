From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] chelsio: Remove remnants of CONFIG_CHELSIO_T1_COUGAR
Date: Thu, 03 Jun 2010 03:22:12 -0700 (PDT)
Message-ID: <20100603.032212.11982365.davem@davemloft.net>
References: <ada39x5tioj.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55480
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933555Ab0FCKWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:22:02 -0400
In-Reply-To: <ada39x5tioj.fsf@roland-alpha.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Wed, 02 Jun 2010 11:04:28 -0700

> CONFIG_CHELSIO_T1_COUGAR cannot be set (it appears nowhere in any
> Kconfig files), and the code it protects could never build (cspi.h was
> never added to the kernel tree).  Therefore it's pretty safe to remove
> all vestiges of this dead code.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>

Applied.
