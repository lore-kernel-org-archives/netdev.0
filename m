From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 2/4 net-next] tcp: refactor undo functions
Date: Wed, 29 May 2013 20:44:42 -0400
Message-ID: <CADVnQymAvpj4FGYGZrzrGtcbxuGCxBDTLwDF8Mt+u_kEjGTnXQ@mail.gmail.com>
References: <1369873214-29502-1-git-send-email-ycheng@google.com>
	<1369873214-29502-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Andreas Terzis <aterzis@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:43749 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab3E3Aop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 20:44:45 -0400
Received: by mail-ob0-f178.google.com with SMTP id fb19so4255680obc.23
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 17:44:43 -0700 (PDT)
In-Reply-To: <1369873214-29502-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 29, 2013 at 8:20 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Refactor and relocate various functions or variables to prepare the
> undo fix.  Remove some unused function arguments. Rename tcp_undo_cwr
> to tcp_undo_cwnd_reduction to be consistent with the rest of
> CWR related function names.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>
