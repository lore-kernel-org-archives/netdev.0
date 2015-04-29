From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp_westwood: fix tcp_westwood_info()
Date: Wed, 29 Apr 2015 19:36:27 -0400
Message-ID: <CADVnQynFp3XXCnt6K7tTMHrA+tEHe7Z4ujnkaJ_jbzrPokzJtQ@mail.gmail.com>
References: <1430263429-4069-1-git-send-email-edumazet@google.com>
	<1430263429-4069-2-git-send-email-edumazet@google.com>
	<20150429.181252.2106091176943411796.davem@davemloft.net>
	<1430347239.3711.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<1430349658.3711.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	kbuild test robot <fengguang.wu@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:33830 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbbD2Xg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 19:36:27 -0400
Received: by obfe9 with SMTP id e9so32345953obf.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 16:36:27 -0700 (PDT)
In-Reply-To: <1430349658.3711.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 7:20 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> I forgot to update tcp_westwood when changing get_info() behavior,
> this patch should fix this.
>
> Fixes: 64f40ff5bbdb ("tcp: prepare CC get_info() access from getsockopt()")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
