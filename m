From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v2 0/3] strp: Stream parser for messages
Date: Mon, 1 Aug 2016 13:38:46 -0700
Message-ID: <CALx6S37EMYLXW28SETev-hJTFS=q_r-qPSzJeuyTM8Wj7yjBsw@mail.gmail.com>
References: <1470069200-3279258-1-git-send-email-tom@herbertland.com> <20160801.132722.1134084069187483498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33333 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755025AbcHAUpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 16:45:22 -0400
Received: by mail-io0-f180.google.com with SMTP id 38so194425347iol.0
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2016 13:45:09 -0700 (PDT)
In-Reply-To: <20160801.132722.1134084069187483498.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 1, 2016 at 1:27 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Mon, 1 Aug 2016 09:33:17 -0700
>
>>   - Remove GPL module license from strparser.c
>
> Why?

It looked more consistent with other modules. Is GPL module license
preferred then?

Tom
