From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 2/3] tcp: move tcp_update_cwnd_in_recovery
Date: Sun, 2 Sep 2012 23:57:02 -0400
Message-ID: <CADVnQy=RH=3bGhfiKpMBCY-6n16FY9iSXBRWDbbT7h+5FbKKWg@mail.gmail.com>
References: <1346643484-12947-1-git-send-email-ycheng@google.com>
	<1346643484-12947-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Nandita Dukkipati <nanditad@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63548 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755030Ab2ICD5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 23:57:03 -0400
Received: by iahk25 with SMTP id k25so3714747iah.19
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2012 20:57:03 -0700 (PDT)
In-Reply-To: <1346643484-12947-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 2, 2012 at 11:38 PM, Yuchung Cheng <ycheng@google.com> wrote:
> To prepare replacing rate halving with PRR algorithm in CWR state.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
