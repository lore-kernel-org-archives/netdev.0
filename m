From: Debashis Dutt <debdut@gmail.com>
Subject: Re: [PATCH] net: bna: convert to hw_features
Date: Tue, 12 Apr 2011 14:56:05 -0700
Message-ID: <BANLkTimGACAprJa2miQOiOZqN5kY2HGeJQ@mail.gmail.com>
References: <20110412193823.177C613A64@rere.qmqm.pl>
	<20110412.145259.102551828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org, rmody@brocade.com,
	ddutt@brocade.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54516 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932227Ab1DLV4H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 17:56:07 -0400
Received: by fxm17 with SMTP id 17so65980fxm.19
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 14:56:05 -0700 (PDT)
In-Reply-To: <20110412.145259.102551828.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/4/12 David Miller <davem@davemloft.net>:
> From: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
> Date: Tue, 12 Apr 2011 21:38:23 +0200 (CEST)
>
>> Note: looks like bnad->conf_mutex is duplicating rtnl_lock.
>>
>> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
>
> Applied.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Thanks Michal & David.

Patch looks good. We will still do some unit-testing and let you know,
in case of any hiccups.

Thanks
--Debashis
