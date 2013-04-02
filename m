From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ISDN:divert: beautify code: useless 'break', 'return
 (0)', additional comments.
Date: Tue, 02 Apr 2013 14:31:35 -0400 (EDT)
Message-ID: <20130402.143135.1804163853965679407.davem@davemloft.net>
References: <5158E854.7060902@asianux.com>
	<515993E1.5010508@cogentembedded.com>
	<515A3674.7090606@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, isdn@linux-pingi.de,
	jslaby@suse.cz, trivial@kernel.org, tilman@imap.cc,
	netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758373Ab3DBSbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 14:31:38 -0400
In-Reply-To: <515A3674.7090606@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Tue, 02 Apr 2013 09:37:56 +0800

> 
>   delete useless 'break' after 'return'.
>   let 'return 0' instead of 'return (0)'
>   also give a comment for 'break' to let readers notice it.
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
