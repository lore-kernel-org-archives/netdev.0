From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] staging: r8712u: fix bug in r8712_recv_indicatepkt()
Date: Wed, 12 Sep 2012 20:25:42 +0200
Message-ID: <1347474342.13103.1278.camel@edumazet-glaptop>
References: <CAKNFNKoowxSsbkV_tsBDG1uZeuWBDxPQFQoHQZ2R2O7Y6hnrmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: Aki Parviainen <aki.parviainen@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48808 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752763Ab2ILSZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 14:25:48 -0400
Received: by bkwj10 with SMTP id j10so73187bkw.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 11:25:47 -0700 (PDT)
In-Reply-To: <CAKNFNKoowxSsbkV_tsBDG1uZeuWBDxPQFQoHQZ2R2O7Y6hnrmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-12 at 20:52 +0300, Aki Parviainen wrote:

> Tested this patch on 64bit linux-3.6-rc5 & fixes problem for me. Thank
> you very much for fixing this very annoying & long time open bug!
> 
> Tested-by: Aki Parviainen <aki.parviainen@iki.fi>

Thanks for testing !
