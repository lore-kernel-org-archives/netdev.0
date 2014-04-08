From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH v3] net: add a sysctl to reflect the fwmark on replies
Date: Tue, 8 Apr 2014 09:22:14 +0900
Message-ID: <CAKD1Yr2nHnt7UqypRBqMEaeYaZLvrNRXrz1=Z2W=ctt3JXguGw@mail.gmail.com>
References: <1396915131-20353-1-git-send-email-lorenzo@google.com> <20140407.200638.1315731010863669193.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Julian Anastasov <ja@ssi.bg>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:62619 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754690AbaDHAWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 20:22:34 -0400
Received: by mail-ie0-f172.google.com with SMTP id as1so198323iec.3
        for <netdev@vger.kernel.org>; Mon, 07 Apr 2014 17:22:34 -0700 (PDT)
In-Reply-To: <20140407.200638.1315731010863669193.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 8, 2014 at 9:06 AM, David Miller <davem@davemloft.net> wrote:
> This is a new feature, which should be targetted at net-next, which
> is closed at this time.
>
> Please resubmit this when the net-next tree opens back up, and
> properly tag your subject line with "net-next" so that it is clear
> what tree your change is targetted at.

Sorry. I thought I saw other net-next patches being reviewed, so I
thought the tree was open again. Will resubmit with amended subject
after -rc1 is released. (That's when the tree reopens, right? I read
the FAQ but it wasn't 100% clear on this point.)
