From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 2/3 net-next] tcp: refactor CA_Loss state processing
Date: Wed, 6 Mar 2013 16:07:06 -0500
Message-ID: <CADVnQykmYqqdjkhvUuL=mqddTj5_88ZRGDvbFyOkh1O=WtLY1w@mail.gmail.com>
References: <1362603130-16501-1-git-send-email-ycheng@google.com>
	<1362603130-16501-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	ilpo.jarvinen@cs.helsinki.fi, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:33300 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551Ab3CFVHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 16:07:08 -0500
Received: by mail-ee0-f42.google.com with SMTP id b47so5975892eek.1
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 13:07:07 -0800 (PST)
In-Reply-To: <1362603130-16501-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 6, 2013 at 3:52 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Consolidate all of TCP CA_Loss state processing in
> tcp_fastretrans_alert() into a new function called tcp_process_loss().
> This is to prepare the new F-RTO implementation in the next patch.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
