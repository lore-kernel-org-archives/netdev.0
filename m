From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: ssh server etc doesn't work anymore with net-2.6
Date: Sun, 11 Apr 2010 02:32:33 -0700
Message-ID: <u2v86802c441004110232l99be1450w4e629ab2bde9bc0c@mail.gmail.com>
References: <r2v86802c441004110217u15591f95ydd1e8e1466a36dc2@mail.gmail.com>
	 <20100411.022416.107236208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:61245 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272Ab0DKJce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 05:32:34 -0400
In-Reply-To: <20100411.022416.107236208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 11, 2010 at 2:24 AM, David Miller <davem@davemloft.net> wrote:
> From: Yinghai Lu <yinghai@kernel.org>
> Date: Sun, 11 Apr 2010 02:17:09 -0700
>
>> it will make sshd server, telnet server and vnc server doesn't respond
>> connecting request anymore.
>
> What kind of network device are you using?
>
> And regardless of the underlying physical network device, are you
> going over some virtual device such as a tunnel, a bonding device, or
> a virtualization network interface?

server side: 82576 with net-2.6
client side: opensuse 11.2 on thinkpad T61 wireless + vpnc

Yinghai
