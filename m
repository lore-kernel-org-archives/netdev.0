From: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Tue, 16 Oct 2012 18:07:14 +0200
Message-ID: <CAO_aot66K-7Je8dSnYTxxkoaDgQ3JpG7t=MdTK0A0ixPX_AP-A@mail.gmail.com>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	<1350242941.21172.17023.camel@edumazet-glaptop>
	<CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	<1350244485.21172.17077.camel@edumazet-glaptop>
	<CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
	<1350246314.21172.17139.camel@edumazet-glaptop>
	<1350246414.21172.17144.camel@edumazet-glaptop>
	<1350246481.21172.17147.camel@edumazet-glaptop>
	<CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
	<1350248858.21172.17197.camel@edumazet-glaptop>
	<CAO_aot6w9yaWacK9kE66m+Lv0LWXY9hKzLH8b=1dp=23fo_W2A@mail.gmail.com>
	<1350250542.21172.17229.camel@edumazet-glaptop>
	<CAO_aot4RiTbUd=7L5e4btLEeJvgy0B3iswaXo8m3AP2qp9Z0TQ@mail.gmail.com>
	<1350252091.21172.17257.camel@edumazet-glaptop>
	<CAO_aot6j2TPe9yxnA1ktMQsfnnWF1XwmCrQUmCcfOqCqbc6dZA@mail.gmail.com>
	<1350279753.21172.17290.camel@edumazet-glaptop>
	<1350285275.22442.17.camel@joe-AO722>
	<1350286790.21172.17414.camel@edumazet-glaptop>
	<1350300302.22442.25.camel@joe-AO722>
	<1350304308.3954.66.camel@edumazet-glaptop>
	<CAO_aot59XNERsb7q9pZSpSzyFLv=pKEk6wb82PE-sNMf4TDXow@mail.gmail.com>
	<1350307293.3954.119.camel@edumazet-glaptop>
	<CAO_aot44shT8CKtCi8Zv0GWN7wjybHX+d5SFQ1daVOh84v+L1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:54894 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105Ab2JPQHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 12:07:15 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so10068706iea.19
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2012 09:07:14 -0700 (PDT)
In-Reply-To: <CAO_aot44shT8CKtCi8Zv0GWN7wjybHX+d5SFQ1daVOh84v+L1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/10/15 Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>:
>
> Yes. Attached..

Today I read about the existence of the "git bisect" function and if I
have not done anything wrong the "bad commit" which lead to this
regression is ddbe503203855939946430e39bae58de11b70b69.
Perhaps this can help you.
