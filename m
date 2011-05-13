From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] olympic: convert to seq_file
Date: Fri, 13 May 2011 16:51:01 -0400 (EDT)
Message-ID: <20110513.165101.783039351348710195.davem@davemloft.net>
References: <20110513204203.GB29261@p183>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755403Ab1EMUvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 16:51:04 -0400
In-Reply-To: <20110513204203.GB29261@p183>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 13 May 2011 23:42:03 +0300

> ->read_proc interface is going away, switch to seq_file.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next-2.6, thanks Alexey.
