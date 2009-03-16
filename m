From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] r8169: use hardware auto-padding.
Date: Sun, 15 Mar 2009 20:04:49 -0700 (PDT)
Message-ID: <20090315.200449.247254502.davem@davemloft.net>
References: <20090315110954.GA17800@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, mikpe@it.uu.se, tdurack@gmail.com,
	ivecera@redhat.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59629
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752037AbZCPDFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 23:05:03 -0400
In-Reply-To: <20090315110954.GA17800@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sun, 15 Mar 2009 12:09:54 +0100

> It shortens the code and fixes the current pci_unmap leak with
> padded skb reported by Dave Jones.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Applied.
