From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 06/10] net/mlx4_core: Fix struct mlx4_vhcr_cmd
 to make implicit padding explicit
Date: Tue, 27 Jan 2015 21:50:40 +0200
Message-ID: <20150127215040.454b1560@jpm-OptiPlex-GX620>
References: <1422351179-27284-1-git-send-email-amirv@mellanox.com>
	<1422351179-27284-7-git-send-email-amirv@mellanox.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD3B01@AcuExch.aculab.com>
	<20150127.111334.501141232585900738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, amirv@mellanox.com,
	netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:52741 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759603AbbA0Ttk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 14:49:40 -0500
Received: by mail-we0-f171.google.com with SMTP id k11so14505828wes.2
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 11:49:39 -0800 (PST)
In-Reply-To: <20150127.111334.501141232585900738.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jan 2015 11:13:34 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> Indeed, I'm really sick of seeing these packed structures being
> created all over the place.
> 
> They are to be used in absolutely extreme cases where no other
> solution is possible.

The V2 of this patch does not have "packed".

-Jack
