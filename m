From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1]core:Change a wrong explain about dev_get_by_name
Date: Wed, 20 Mar 2013 10:43:09 -0700
Message-ID: <1363801389.3333.25.camel@edumazet-glaptop>
References: <CA+qZnSSMfbeGsThYe-=tK-kZ3h1GEKDGkNom+07-hRSqgLUUWg@mail.gmail.com>
	 <1363793549.3333.12.camel@edumazet-glaptop>
	 <1363799443.2677.2.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tingwei liu <tingw.liu@gmail.com>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:33473 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754430Ab3CTRnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:43:12 -0400
Received: by mail-ia0-f174.google.com with SMTP id b35so1615129iac.5
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 10:43:11 -0700 (PDT)
In-Reply-To: <1363799443.2677.2.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-20 at 17:10 +0000, Ben Hutchings wrote:

> If they are wrongly documented as 'can be called from any context', yes.

Wow, thats really useful.

Why is this function not allowed from hard irq context, we have no idea.

Why someone would like to call it from hard irq context, we have no
idea.

I hope to get a clear explanation here, not only playing with words.

Thanks
