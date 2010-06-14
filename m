From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH v4] netfilter: Xtables: idletimer target implementation
Date: Mon, 14 Jun 2010 17:39:30 +0300
Message-ID: <1276526370.2092.33.camel@chilepepper>
References: <1276264913-429-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>,
	Timo Teras <timo.teras@iki.fi>
To: "netfilter-devel@vger.kernel.org" <netfilter@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:54066 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861Ab0FNOkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 10:40:12 -0400
In-Reply-To: <1276264913-429-1-git-send-email-luciano.coelho@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-06-11 at 16:01 +0200, Coelho Luciano (Nokia-D/Helsinki)
wrote:
> v4: Fixed according to Jan's and Patrick's comments to v3
>     Changed to mutex locking instead of spin locks
>     Save the timer in the target info struct to avoid extra reads
>     Other small clean-ups

Does the patch look okay now? Any further comments?


-- 
Cheers,
Luca.

