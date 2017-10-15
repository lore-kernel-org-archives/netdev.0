From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] nfp: Explicitly include linux/bug.h
Date: Sat, 14 Oct 2017 18:31:52 -0700 (PDT)
Message-ID: <20171014.183152.556133969386350823.davem@davemloft.net>
References: <20171013025035.4450-1-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, simon.horman@netronome.com,
        oss-drivers@netronome.com, netdev@vger.kernel.org
To: broonie@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38212 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751165AbdJOBbx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 21:31:53 -0400
In-Reply-To: <20171013025035.4450-1-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>
Date: Fri, 13 Oct 2017 03:50:35 +0100

> Today's -next build encountered an error due to a missing definition of
> WARN_ON(), caused by some header reorganization removing an implicit
> inclusion of linux/bug.h.  Fix this with an explicit inclusion.
> 
> Signed-off-by: Mark Brown <broonie@kernel.org>

Applied, thanks Mark.
