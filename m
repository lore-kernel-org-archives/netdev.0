From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 0/5] iptables lockless receive (v0.3)
Date: Thu, 29 Jan 2009 09:07:53 +0100
Message-ID: <498163D9.6030304@cosmosbay.com>
References: <20090129062521.092861272@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49414 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756713AbZA2IH4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 03:07:56 -0500
In-Reply-To: <20090129062521.092861272@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Another experimental version of iptables locking that removes
> reader/writer lock overhead. This version incorprates suggestion
> of moving counter to table_info.  I haven't done ebtables, and don't
> know if it is worth bothering.
>=20

A fast review reveals no problems, this looks good.

I will do some testings today and give a feedback.

By the way, you forgot to CC Patrick McHardy and netfilter-devel

Thanks a lot Stephen

