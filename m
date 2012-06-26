From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Remove unnecessary code from rt_check_expire().
Date: Tue, 26 Jun 2012 09:58:33 +0200
Message-ID: <1340697513.10893.211.camel@edumazet-glaptop>
References: <20120626.002124.2220875506847485306.davem@davemloft.net>
	 <1340696398.10893.209.camel@edumazet-glaptop>
	 <20120626.004658.2123525722448546355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34469 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755535Ab2FZH6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 03:58:38 -0400
Received: by bkcji2 with SMTP id ji2so3884961bkc.19
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 00:58:36 -0700 (PDT)
In-Reply-To: <20120626.004658.2123525722448546355.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 00:46 -0700, David Miller wrote:

> But regardless, could you actually answer the question I asked of you?

I did a revert, no more no less.
