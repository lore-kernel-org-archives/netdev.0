From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2] net: consolidate netif_needs_gso()
 checks
Date: Sun, 28 Feb 2010 00:30:18 -0800 (PST)
Message-ID: <20100228.003018.102550611.davem@davemloft.net>
References: <20100227001954.32474.62766.stgit@localhost.localdomain>
	<20100227.032725.158512690.davem@davemloft.net>
	<20100227155245.GB3176@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, john.r.fastabend@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33186
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031531Ab0B1I37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 03:29:59 -0500
In-Reply-To: <20100227155245.GB3176@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jeff and John, please address Herbert's feedback and I'll apply
this patch.

Thanks!
