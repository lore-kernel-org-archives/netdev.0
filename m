From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCHES 0/6] Turn skb->nh into a union of just one member 8)
Date: Mon, 12 Mar 2007 23:59:53 -0300
Message-ID: <39e6f6c70703121959i27a68149l529765d04625d375@mail.gmail.com>
References: <39e6f6c70703121827i521e24dbv72dff3ae1d92a268@mail.gmail.com>
	 <20070312.195240.11958487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:9049 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753071AbXCMC74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 22:59:56 -0400
Received: by ug-out-1314.google.com with SMTP id 44so103069uga
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 19:59:54 -0700 (PDT)
In-Reply-To: <20070312.195240.11958487.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/12/07, David Miller <davem@davemloft.net> wrote:
> From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
> Date: Mon, 12 Mar 2007 22:27:06 -0300
>
> > Hi David,
> >
> >           Please consider pulling from:
> >
> > master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22
> >
> >            As the last csets says its just a temporary situation :-)
>
> There is no stopping you today is there? :-)

Well, after some dccp initial reviewing I'm calling the day finished,
will try to continue with DCCP tomorrow and then get back at the
transport layer header pointer. :-)

> Pulled and pushed out, thanks a lot!

Thanks!

g'night.

- Arnaldo
