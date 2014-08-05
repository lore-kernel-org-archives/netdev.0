From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] team: Simplify return path of team_newlink
Date: Tue, 5 Aug 2014 09:06:42 +0200
Message-ID: <20140805070642.GA1879@nanopsycho.orion>
References: <1407221930-15590-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:43517 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756006AbaHEHGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 03:06:45 -0400
Received: by mail-wg0-f52.google.com with SMTP id a1so495151wgh.23
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2014 00:06:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1407221930-15590-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 05, 2014 at 08:58:50AM CEST, makita.toshiaki@lab.ntt.co.jp wrote:
>The variable "err" is not necessary.
>Return register_netdevice() directly.
>
>Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Acked-by: Jiri Pirko <jiri@resnulli.us>
