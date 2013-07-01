From: Roland Dreier <roland@kernel.org>
Subject: Re: [PATCH for-next 0/8] Add Mellanox mlx5 driver for Connect-IB devices
Date: Mon, 1 Jul 2013 11:11:50 -0700
Message-ID: <CAL1RGDW_Z06ZqpOhz3tAkKn=rpLEZE6hWZkLNd9OQgCbrX6YAg@mail.gmail.com>
References: <1371384149-24558-1-git-send-email-eli@dev.mellanox.co.il>
 <CAJZOPZ+NQa3CWnw3rZQh2UuwdrNhiwtVSyuk9D9YtwfQQ9e1XA@mail.gmail.com>
 <CAJZOPZKLb9k1xXkTnrtzYKpwrSJDQgBpONUVCp3et36JeaEi-Q@mail.gmail.com>
 <CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw@mail.gmail.com> <1372701839.2481.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Eli Cohen <eli@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog103.obsmtp.com ([74.125.245.74]:59537 "HELO
	na3sys010aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754801Ab3GASMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 14:12:12 -0400
Received: by mail-la0-f44.google.com with SMTP id er20so4725834lab.3
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 11:12:10 -0700 (PDT)
In-Reply-To: <1372701839.2481.3.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 1, 2013 at 11:03 AM, Joe Perches <joe@perches.com> wrote:
> There's some value in block enabling/disabling messages
> that dynamic_debug doesn't currently offer.

As far as I can see, the mlx5 stuff ends up being per-file.  Which
dynamic debug already does offer.

 - R.
