From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/2] pktgen changes
Date: Sat, 09 May 2015 22:26:22 -0400 (EDT)
Message-ID: <20150509.222622.1324115471836653774.davem@davemloft.net>
References: <554A26A4.1000505@plumgrid.com>
	<20150507143329.8534.49710.stgit@ivy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, ast@plumgrid.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbbEJC0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 22:26:24 -0400
In-Reply-To: <20150507143329.8534.49710.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 07 May 2015 16:34:29 +0200

> The following series introduce some pktgen changes
> 
> Patch01:
>  Cleanup my own work when I introduced NO_TIMESTAMP.
> 
> Patch02:
>  Took over patch from Alexei, and addressed my own concerns, as Alexie
>  is too busy with other work, and this will provide an easy tool for
>  measuring ingress path performance, which is a hot topic ATM.
> 
>  Changes were primarily user interface related.  Introduced a separate
>  "xmit_mode" setting, instead of stealing one of the dev flags like
>  Alexei did.

Series applied, thanks Jesper.
