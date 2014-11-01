From: Cong Wang <cwang@twopensource.com>
Subject: Re: [stable request <= 3.11] net/mlx4_en: Fix BlueFlame race
Date: Sat, 1 Nov 2014 10:17:43 -0700
Message-ID: <CAHA+R7OyLv2YO8AduNhnEgW3RyYZwWNEHY6W-v_HXgVT9AOaKw@mail.gmail.com>
References: <CAHTgTXVn1479XCoh1-j=Xghtad3zA-hf0za5r_AyoaKuKeFZ2g@mail.gmail.com>
	<1414805353.16849.98.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vinson Lee <vlee@twopensource.com>,
	"David S. Miller" <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:55240 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbaKARRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 13:17:45 -0400
Received: by mail-lb0-f174.google.com with SMTP id z11so5510655lbi.19
        for <netdev@vger.kernel.org>; Sat, 01 Nov 2014 10:17:43 -0700 (PDT)
In-Reply-To: <1414805353.16849.98.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2014 at 6:29 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Sat, 2014-10-18 at 14:14 -0700, Vinson Lee wrote:
>> Hi.
>>
>> Please consider backporting upstream commit
>> 2d4b646613d6b12175b017aca18113945af1faf3 "net/mlx4_en: Fix BlueFlame
>> race" to stable kernels <= 3.11.
>>
>> commit 2d4b646613d6b12175b017aca18113945af1faf3
>> Author: Eugenia Emantayev <eugenia@mellanox.com>
>> Date:   Thu Jul 25 19:21:23 2013 +0300
>>
>>     net/mlx4_en: Fix BlueFlame race
> [...]
>
> David doesn't support anything older than 3.12 now, so you should send
> requests for older stable branches directly to the stable list.

Interesting, is there a document saying which stable kernels netdev
supports? and how are they chosen?

I thought netdev supports all -stable maintainers support.

Anyway, we will send the request directly to Greg then.

Thanks.
