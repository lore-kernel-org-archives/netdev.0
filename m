From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v6] rps: selective flow shedding during softnet overflow
Date: Mon, 20 May 2013 12:08:39 -0400
Message-ID: <CA+FuTSdDQAVyGoOwyt22BrmE29HSO8NtQ9oguWh7GHf648yG3A@mail.gmail.com>
References: <20130425.042007.1583080085524610665.davem@davemloft.net>
 <1369058552-2909-1-git-send-email-willemb@google.com> <1369065654.3301.184.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34266 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755788Ab3ETQJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 12:09:10 -0400
Received: by mail-ie0-f169.google.com with SMTP id u16so14223033iet.14
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 09:09:10 -0700 (PDT)
In-Reply-To: <1369065654.3301.184.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Willemb, are you planning to add a section in
> Documentation/networking/scaling.txt ?

Good point, I should. I will send a follow-on patch documenting the
mechanism and sysctls.
