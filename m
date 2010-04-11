From: David Miller <davem@davemloft.net>
Subject: Re: ssh server etc doesn't work anymore with net-2.6
Date: Sun, 11 Apr 2010 02:33:32 -0700 (PDT)
Message-ID: <20100411.023332.119286627.davem@davemloft.net>
References: <r2v86802c441004110217u15591f95ydd1e8e1466a36dc2@mail.gmail.com>
	<20100411.022416.107236208.davem@davemloft.net>
	<u2v86802c441004110232l99be1450w4e629ab2bde9bc0c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org
To: yinghai@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <u2v86802c441004110232l99be1450w4e629ab2bde9bc0c@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yinghai Lu <yinghai@kernel.org>
Date: Sun, 11 Apr 2010 02:32:33 -0700

> On Sun, Apr 11, 2010 at 2:24 AM, David Miller <davem@davemloft.net> wrote:
>> From: Yinghai Lu <yinghai@kernel.org>
>> Date: Sun, 11 Apr 2010 02:17:09 -0700
>>
>>> it will make sshd server, telnet server and vnc server doesn't respond
>>> connecting request anymore.
>>
>> What kind of network device are you using?
>>
>> And regardless of the underlying physical network device, are you
>> going over some virtual device such as a tunnel, a bonding device, or
>> a virtualization network interface?
> 
> server side: 82576 with net-2.6
> client side: opensuse 11.2 on thinkpad T61 wireless + vpnc

Thanks.
