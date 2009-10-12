From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] netxen: fix pci bar mapping
Date: Sun, 11 Oct 2009 23:22:03 -0700 (PDT)
Message-ID: <20091011.232203.41690616.davem@davemloft.net>
References: <1255328031-17189-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49647
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753734AbZJLGWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 02:22:07 -0400
In-Reply-To: <1255328031-17189-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun, 11 Oct 2009 23:13:51 -0700

> Use phys_addr_t data type for pci resource address
> instead of unsigned long. This fixes mapping of
> pci resources where resource addresses can be larger
> than word size (e.g. PAE).
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Lazy, you didn't update the commit log message to match the
change you made to the patch.

I think I'll just ignore your patches for a while until
you start to be a little bit less careless.

Thanks.
