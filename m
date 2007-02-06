From: David Miller <davem@davemloft.net>
Subject: Re: [patch 07/11] remove tcp header from tcp_v4_check
Date: Mon, 05 Feb 2007 18:08:05 -0800 (PST)
Message-ID: <20070205.180805.93386139.davem@davemloft.net>
References: <200702060032.l160W8cb004636@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, deweerdt@free.fr,
	frederik.deweerdt@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57502
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965426AbXBFCIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 21:08:11 -0500
In-Reply-To: <200702060032.l160W8cb004636@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 05 Feb 2007 16:31:05 -0800

> From: Frederik Deweerdt <deweerdt@free.fr>
> 
> The tcphdr struct passed to tcp_v4_check is not used, the following
> patch removes it from the parameter list.
> 
> Signed-off-by: Frederik Deweerdt <frederik.deweerdt@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This one is already in my tree, but thanks for resubmitting.
