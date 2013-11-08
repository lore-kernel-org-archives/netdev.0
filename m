From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] inet: fix a UFO regression
Date: Thu, 07 Nov 2013 21:50:24 -0800
Message-ID: <1383889824.9412.220.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMEtUuyuHagy7j+fi8RnKjZNBnwYHhxfed508HyXLfHp-e634w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:38664 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab3KHFuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 00:50:25 -0500
Received: by mail-pb0-f53.google.com with SMTP id up7so1680675pbc.12
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 21:50:25 -0800 (PST)
In-Reply-To: <CAMEtUuyuHagy7j+fi8RnKjZNBnwYHhxfed508HyXLfHp-e634w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 21:44 -0800, Alexei Starovoitov wrote:

> vxlan looks good through namespaces with and without gso
> and between physical machines via 10G nics
> 
> Tested-by: Alexei Starovoitov <ast@plumgrid.com>
> 
> Thanks Eric!

And I tested the UFO part as well.

Thanks Alexei !
