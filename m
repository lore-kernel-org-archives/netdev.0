From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH] [PATCH] tcp: Increment of LINUX_MIB_LISTENOVERFLOWS in
 tcp_v4_conn_request() (updated)
Date: Sun, 27 Jan 2013 18:01:35 -0800
Message-ID: <CAGK4HS9_xZSWVHBQX3DwvR7swnGqqccdD8mvL-i20a2dnOvK1A@mail.gmail.com>
References: <1359337550-3958-1-git-send-email-niveditasinghvi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Nivedita Singhvi <niv@us.ibm.com>
To: Nivedita Singhvi <niveditasinghvi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:65278 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757180Ab3A1CBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 21:01:36 -0500
Received: by mail-qa0-f45.google.com with SMTP id g10so681338qah.18
        for <netdev@vger.kernel.org>; Sun, 27 Jan 2013 18:01:35 -0800 (PST)
In-Reply-To: <1359337550-3958-1-git-send-email-niveditasinghvi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27 January 2013 17:45, Nivedita Singhvi <niveditasinghvi@gmail.com> wrote:
> From: Nivedita Singhvi <niv@us.ibm.com>
>
> We drop a connection request if the accept backlog is full and there are
> sufficient packets in the syn queue to warrant starting drops. Increment the
> appropriate counter so this isn't silent, for accurate stats and help in
> debugging.
>
> Signed-off-by: Nivedita Singhvi <niv@us.ibm.com>

Acked-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Thanks,
Vijay
