From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make sctp_outq_flush() static
Date: Tue, 22 Jul 2008 14:20:53 -0700 (PDT)
Message-ID: <20080722.142053.12687321.davem@davemloft.net>
References: <20080722172045.GT14846@cs181140183.pp.htv.fi>
	<20080722180532.GD6887@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38638
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750877AbYGVVUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:20:53 -0400
In-Reply-To: <20080722180532.GD6887@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 22 Jul 2008 14:05:32 -0400

> On Tue, Jul 22, 2008 at 08:20:45PM +0300, Adrian Bunk wrote:
> > sctp_outq_flush() can now become static.
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> > 
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
