From: Michael Spang <mspang@csclub.uwaterloo.ca>
Subject: Re: [PATCH] Revert netlink ABI change to gnet_stats_basic
Date: Sun, 16 Aug 2009 16:10:12 -0400
Message-ID: <118a63b80908161310r69c0810fg247341f09ced8932@mail.gmail.com>
References: <1250002683-28554-1-git-send-email-mspang@csclub.uwaterloo.ca>
	 <4A87FCAC.5070705@gmail.com>
	 <118a63b80908160642j73568637n2f3fa97fc33d8e57@mail.gmail.com>
	 <4A885FD1.4030105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:47122 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754753AbZHPUKM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2009 16:10:12 -0400
In-Reply-To: <4A885FD1.4030105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 16, 2009 at 3:36 PM, Eric Dumazet<eric.dumazet@gmail.com> w=
rote:
> Michael Spang a =E9crit :
>
> OK, then we are stuck to use a separate definition for user land
> and kernel land, or risk various side effects, like performance hit
> and security risk.
>
> Thanks a lot Michael
>
> [PATCH] net: restore gnet_stats_basic to previous definition

Applied it and it works for me, thanks.

Michael
