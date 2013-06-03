From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next post Lorenzo] transp_v6.h: style neatening
Date: Mon, 3 Jun 2013 11:20:17 +0900
Message-ID: <CAKD1Yr3hBQWATGwqoxwdMhcrp4wSOXUzE4Kfi2XvmEFkidOJkA@mail.gmail.com>
References: <1370049940.10556.100.camel@joe-AO722> <20130601.195806.2024506377665086082.davem@davemloft.net>
 <1370142368.2086.6.camel@joe-AO722> <20130602.012918.1216932529595713857.davem@davemloft.net>
 <1370164995.2086.30.camel@joe-AO722> <CAKD1Yr0rRBWZ8WcMSo-xoG=X8kptBdhFBk36CjLX72BZkHuSvw@mail.gmail.com>
 <1370192666.7400.16.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:56993 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753050Ab3FCCUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 22:20:38 -0400
Received: by mail-qa0-f52.google.com with SMTP id cr7so1531148qab.18
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 19:20:37 -0700 (PDT)
In-Reply-To: <1370192666.7400.16.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 3, 2013 at 2:04 AM, Joe Perches <joe@perches.com> wrote:
>> I don't have strong feelings about indentation, but if possible I
>> would like to avoid re-spinning this patchset more than twice over
>> formatting changes to this file.
>
> You could do nothing and David could apply this if
> he wants a more complete neatening.

Joe, thanks for saving me a respin. I'd have been happy to do it
myself too, it's just that I'm a bit confused on what the style
actually needs to be.

David - if I have to respin the patch anyway because of other issues
we might uncover, I take it you'd like me to make the new patch use
this indentation?
