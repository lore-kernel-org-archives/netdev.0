From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp/dccp: fix old style declarations
Date: Mon, 05 Oct 2015 04:03:28 -0700 (PDT)
Message-ID: <20151005.040328.273246790497153376.davem@davemloft.net>
References: <1443700133.32531.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raanan.avargil@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39160 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbbJEKrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 06:47:49 -0400
In-Reply-To: <1443700133.32531.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Oct 2015 04:48:53 -0700

> From: Raanan Avargil <raanan.avargil@intel.com>
> 
> I’m using the compilation flag -Werror=old-style-declaration, which
> requires that the “inline” word would come at the beginning of the code
> line.
>  
> $ make drivers/net/ethernet/intel/e1000e/e1000e.ko
 ...
> Fixes: ed2e92394589 ("tcp/dccp: fix timewait races in timer handling")
> Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
