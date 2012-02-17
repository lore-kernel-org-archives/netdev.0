From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: xilinx: Convert xilinx_axienet to
 module_platform_driver
Date: Fri, 17 Feb 2012 16:09:37 -0500 (EST)
Message-ID: <20120217.160937.2049555376655405188.davem@davemloft.net>
References: <4F3E781A.30402@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tklauser@distanz.ch, ariane.keller@tik.ee.ethz.ch,
	netdev@vger.kernel.org
To: danborkmann@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251Ab2BQVK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 16:10:26 -0500
In-Reply-To: <4F3E781A.30402@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <danborkmann@iogearbox.net>
Date: Fri, 17 Feb 2012 16:54:02 +0100

> Tobias Klauser <tklauser@distanz.ch> wrote:
>> Follow commit db62f684. Convert the driver to use the
>> module_platform_driver() macro which makes the code a bit smaller and
>> simpler.
>>
>> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> 
> Acked-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>

Applied.
