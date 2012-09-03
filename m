From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 1/3] tcp: move tcp_enter_cwr()
Date: Sun, 2 Sep 2012 23:56:09 -0400
Message-ID: <CADVnQymfu8YdGT_Rc0GBQ5wzncVQi6-BmTLtzD3MwQV8A3WFUQ@mail.gmail.com>
References: <1346643484-12947-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Nandita Dukkipati <nanditad@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41275 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755030Ab2ICD4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 23:56:11 -0400
Received: by iahk25 with SMTP id k25so3714228iah.19
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2012 20:56:10 -0700 (PDT)
In-Reply-To: <1346643484-12947-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 2, 2012 at 11:38 PM, Yuchung Cheng <ycheng@google.com> wrote:
> To prepare replacing rate halving with PRR algorithm in CWR state.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
