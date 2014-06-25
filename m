From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] trivial: net: filter: Change kerneldoc parameter order
Date: Wed, 25 Jun 2014 16:39:19 -0700 (PDT)
Message-ID: <20140625.163919.1130734465030686421.davem@davemloft.net>
References: <1403616802-25743-1-git-send-email-tklauser@distanz.ch>
	<1403616802-25743-2-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, ast@plumgrid.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602AbaFYXjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 19:39:20 -0400
In-Reply-To: <1403616802-25743-2-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 24 Jun 2014 15:33:21 +0200

> Change the order of the parameters to sk_unattached_filter_create() in
> the kerneldoc to reflect the order they appear in the actual function.
> 
> This fix is only cosmetic, in the generated doc they still appear in the
> correct order without the fix.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
