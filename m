From: Cong Wang <cwang@twopensource.com>
Subject: Re: [stable request <= 3.11] net/mlx4_en: Fix BlueFlame race
Date: Mon, 3 Nov 2014 09:22:18 -0800
Message-ID: <CAHA+R7OMgOpnWyy5E55OtLS4naOcZ5EhzViE14Yffu=K=TqNcA@mail.gmail.com>
References: <CAHTgTXVn1479XCoh1-j=Xghtad3zA-hf0za5r_AyoaKuKeFZ2g@mail.gmail.com>
	<1414805353.16849.98.camel@decadent.org.uk>
	<CAHA+R7OyLv2YO8AduNhnEgW3RyYZwWNEHY6W-v_HXgVT9AOaKw@mail.gmail.com>
	<20141101.134142.888127846627939710.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Vinson Lee <vlee@twopensource.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:59060 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbaKCRWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 12:22:20 -0500
Received: by mail-lb0-f180.google.com with SMTP id u10so1305304lbd.11
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 09:22:18 -0800 (PST)
In-Reply-To: <20141101.134142.888127846627939710.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 1, 2014 at 10:41 AM, David Miller <davem@davemloft.net> wrote:
>
> There is no documented way nor do I wish to state anything so strictly.
> I want maximum flexibility for such a time consuming task.
>
> I tend to go back 3 or 4 releases at most, and it really depends upon
> the difficulty of the backports and my own time constraints.

You should really offload to developers, otherwise too much work for you. :)

Thanks!
