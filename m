From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/3] pf_packet updates
Date: Thu, 29 Aug 2013 03:25:45 -0700
Message-ID: <1377771945.8277.26.camel@edumazet-glaptop>
References: <1377720791-15844-1-git-send-email-dborkman@redhat.com>
	 <20130829.013938.2144325735677512661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:56672 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467Ab3H2KZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 06:25:47 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so267067pdj.29
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 03:25:47 -0700 (PDT)
In-Reply-To: <20130829.013938.2144325735677512661.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-29 at 01:39 -0400, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Wed, 28 Aug 2013 22:13:08 +0200
> 
> > Daniel Borkmann (3):
> >   net: packet: add random fanout scheduler
> >   net: packet: use reciprocal_divide in fanout_demux_hash
> >   net: packet: document available fanout policies
> 
> Please add the missing reciprocal_divide.h include to the second
> patch, as per Eric Dumazet's feedback, and resubmit this series.

(It was Cong Wang feedback ;) )

Thanks
