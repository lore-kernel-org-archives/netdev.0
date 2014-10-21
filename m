From: Cong Wang <cwang@twopensource.com>
Subject: Re: [stable request <= 3.11] net/mlx4_en: Fix BlueFlame race
Date: Tue, 21 Oct 2014 16:15:31 -0700
Message-ID: <CAHA+R7MSiuazaAr-F5UGZ+DYv-8EE5mLmVtvjVvfC7iYY9+i=Q@mail.gmail.com>
References: <CAHTgTXVn1479XCoh1-j=Xghtad3zA-hf0za5r_AyoaKuKeFZ2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	netdev <netdev@vger.kernel.org>
To: Vinson Lee <vlee@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:62203 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369AbaJUXPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 19:15:32 -0400
Received: by mail-qg0-f49.google.com with SMTP id e89so1682206qgf.22
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2014 16:15:32 -0700 (PDT)
In-Reply-To: <CAHTgTXVn1479XCoh1-j=Xghtad3zA-hf0za5r_AyoaKuKeFZ2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 18, 2014 at 2:14 PM, Vinson Lee <vlee@twopensource.com> wrote:
> Hi.
>
> Please consider backporting upstream commit
> 2d4b646613d6b12175b017aca18113945af1faf3 "net/mlx4_en: Fix BlueFlame
> race" to stable kernels <= 3.11.
>

David, could you take care of it if you have time? It fixes a real
bug in production. :)

Thanks a lot!
