From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [Patch 1/2]r8169: remove rtl_rw_cpluscmd
Date: Fri, 4 Jun 2010 09:37:14 +0800
Message-ID: <AANLkTinU-eRWzHV2HD7rGdC5sECkoEinDmZHZw9_llez@mail.gmail.com>
References: <20100603112428.GC24909@host-a-55.ustcsz.edu.cn>
	<20100603214257.GA3327@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:38359 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932217Ab0FDBhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 21:37:16 -0400
Received: by gye5 with SMTP id 5so576885gye.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 18:37:15 -0700 (PDT)
In-Reply-To: <20100603214257.GA3327@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'll figure that there may be some value in the patch if you
> test the change on revision X, Y and Z.

Frankly, I just tested the patch on my NIC. It works fine.

>
> Some cosmetic isolated in a sequence of changes can be fine too.
>
> Otherwise I consider such cleanups as a (useless and) conceivably
> harmful distraction.

As I said, those points really confused me while I was going over the
driver. I searched google and mailing list archive but failed to get
any traces. It seems they exist for a long time without any touch
(care). So I decided to post the patches to see whether they are
harmful or not.

OK. I'll bypass legacy hardware-related codes since they are really
very tricky. :)

Thanks Francois.

-- 
--Junchang
