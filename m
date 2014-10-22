From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [stable request <= 3.11] net/mlx4_en: Fix BlueFlame race
Date: Wed, 22 Oct 2014 07:17:43 +0300
Message-ID: <CAJ3xEMiOEZ9fDtLd4qqPmqAGb3hZneBXidyaxA9Pv1Ki6cKnAg@mail.gmail.com>
References: <CAHTgTXVn1479XCoh1-j=Xghtad3zA-hf0za5r_AyoaKuKeFZ2g@mail.gmail.com>
	<CAHA+R7MSiuazaAr-F5UGZ+DYv-8EE5mLmVtvjVvfC7iYY9+i=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vinson Lee <vlee@twopensource.com>,
	"David S. Miller" <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	netdev <netdev@vger.kernel.org>, saeedm@mellanox.com
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:45179 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbaJVERo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 00:17:44 -0400
Received: by mail-oi0-f51.google.com with SMTP id h136so2097530oig.24
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2014 21:17:43 -0700 (PDT)
In-Reply-To: <CAHA+R7MSiuazaAr-F5UGZ+DYv-8EE5mLmVtvjVvfC7iYY9+i=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2014 at 2:15 AM, Cong Wang <cwang@twopensource.com> wrote:
> On Sat, Oct 18, 2014 at 2:14 PM, Vinson Lee <vlee@twopensource.com> wrote:
>> Hi.
>>
>> Please consider backporting upstream commit
>> 2d4b646613d6b12175b017aca18113945af1faf3 "net/mlx4_en: Fix BlueFlame
>> race" to stable kernels <= 3.11.
>>
>
> David, could you take care of it if you have time? It fixes a real
> bug in production. :)

Let out folks here look on that 1st.

Or.
