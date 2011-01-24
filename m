From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] dcbnl: make get_app handling symmetric for
 IEEE and CEE DCBx
Date: Mon, 24 Jan 2011 15:20:05 -0800 (PST)
Message-ID: <20110124.152005.245411330.davem@davemloft.net>
References: <20110122023512.4239.40379.stgit@jf-dev1-dcblab>
	<20110122023518.4239.3464.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shmulikr@broadcom.com, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60047
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752520Ab1AXXTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 18:19:30 -0500
In-Reply-To: <20110122023518.4239.3464.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Fri, 21 Jan 2011 18:35:18 -0800

> The IEEE get/set app handlers use generic routines and do not
> require the net_device to implement the dcbnl_ops routines. This
> patch makes it symmetric so user space and drivers do not have
> to handle the CEE version and IEEE DCBx versions differently.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied, thanks John.
