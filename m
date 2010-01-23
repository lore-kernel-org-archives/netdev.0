From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: simplify seq_file code
Date: Sat, 23 Jan 2010 01:21:48 -0800 (PST)
Message-ID: <20100123.012148.107862568.davem@davemloft.net>
References: <20100122201605.GB22342@x200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38059
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752849Ab0AWJVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:21:36 -0500
In-Reply-To: <20100122201605.GB22342@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 22 Jan 2010 22:16:05 +0200

> Simpily pass 'struct neigh_table' with seq_file private pointer,
> and save one dereference. Proc entry itself isn't interesting.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
