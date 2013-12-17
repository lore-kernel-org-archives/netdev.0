From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: sit: update mtu check to take care of gso packets
Date: Tue, 17 Dec 2013 06:48:57 -0800
Message-ID: <1387291737.19078.258.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52AB322B.7030802@redhat.com>
	 <1387204283.19078.240.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52B05E2D.6060001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:55100 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401Ab3LQOs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 09:48:59 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so7031903pbc.21
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 06:48:59 -0800 (PST)
In-Reply-To: <52B05E2D.6060001@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-17 at 15:22 +0100, Michal Schmidt wrote:

> Tested-by: Michal Schmidt <mschmidt@redhat.com>
> 
> It works fine now. Thanks.
> Michal

Thanks a lot Michal for your very nice bug report !
