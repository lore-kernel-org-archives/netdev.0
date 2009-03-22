From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH] Phonet:fix build problem
Date: Sun, 22 Mar 2009 03:19:25 +0300
Message-ID: <a4423d670903211719m76baeab0k51f054058d6f5134@mail.gmail.com>
References: <20090320115838.GA26371@orion>
	 <20090321.165950.248659848.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kyle@mcmartin.ca, linux-parisc@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20090321.165950.248659848.davem@davemloft.net>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/3/22 David Miller <davem@davemloft.net>:
> From: Alexander Beregalov <a.beregalov@gmail.com>
> Date: Fri, 20 Mar 2009 14:58:38 +0300
>
>> net/phonet/pep.c: In function 'pipe_rcv_status':
>> net/phonet/pep.c:262: error: lvalue required as left operand of assignment
>>
>> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
>
> What platform hits this problem?
>
> I think that platform's atomic_add() implementation should
> be fixed instead.

It is parisc, CC added.
