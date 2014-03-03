From: zbr@ioremap.net
Subject: Re: [PATCH] connector: remove duplicated code in cn_call_callback()
Date: Tue, 04 Mar 2014 00:42:40 +0400
Message-ID: <181701393879360@web25g.yandex.ru>
References: <1393704056-13943-1-git-send-email-khoroshilov@ispras.ru> <20140303.153945.218115412923126825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"khoroshilov@ispras.ru" <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140303.153945.218115412923126825.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everyone

04.03.2014, 00:39, "David Miller" <davem@davemloft.net>:
> From: Alexey Khoroshilov <khoroshilov@ispras.ru>
> Date: Sun, =9A2 Mar 2014 00:00:56 +0400
>
>> =9AThere were a couple of patches fixing the same bug that
>> =9Aresults in duplicated err =3D 0; assignment.
>> =9AThe patch removes one of them.
>>
>> =9ASigned-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
>
> Applied to net-next, thank you.

Thank you
