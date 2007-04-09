From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 2.6.21]: cls_tcindex: fix compatibility breakage
Date: Mon, 09 Apr 2007 11:42:51 -0700 (PDT)
Message-ID: <20070409.114251.97268455.davem@davemloft.net>
References: <461A6A32.2040809@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40182
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753364AbXDISmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 14:42:52 -0400
In-Reply-To: <461A6A32.2040809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 09 Apr 2007 18:30:42 +0200

> Fix tcindex userspace compatibility breakage on big-endian.
> Patch applies to current -git and -stable.

Applied, thanks Patrick.

I'll push to -stable later today.
