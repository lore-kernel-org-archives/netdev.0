From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] netconf: add proxy-arp support
Date: Fri, 13 Dec 2013 09:43:05 +0100
Message-ID: <52AAC899.801@6wind.com>
References: <20131212130650.52c7b267@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:55814 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124Ab3LMInI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 03:43:08 -0500
Received: by mail-wg0-f45.google.com with SMTP id y10so1571587wgg.24
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 00:43:07 -0800 (PST)
In-Reply-To: <20131212130650.52c7b267@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/12/2013 22:06, Stephen Hemminger a =E9crit :
> Add support to netconf to show changes to proxy-arp status on a per
> interface basis via netlink in a manner similar to forwarding
> and reverse path state.
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

I suppose that the iproute2 patch will follow.
Do you plan to add PROXY_NDP too?
