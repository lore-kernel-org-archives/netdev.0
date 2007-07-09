From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/8] Make ATM driver use seq_list_xxx helpers
Date: Mon, 09 Jul 2007 13:12:53 -0700 (PDT)
Message-ID: <20070709.131253.51841085.davem@davemloft.net>
References: <200707091851.l69Ip9PI001723@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@sw.ru, xemul@openvz.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45863
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752707AbXGIUMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 16:12:31 -0400
In-Reply-To: <200707091851.l69Ip9PI001723@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 09 Jul 2007 11:51:09 -0700

> From: Pavel Emelianov <xemul@sw.ru>
> 
> The .show callback receives the list_head pointer now, not the struct
> br2684_dev one.
> 
> Signed-off-by: Pavel Emelianov <xemul@openvz.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
