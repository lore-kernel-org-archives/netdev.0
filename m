From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 2/3] netconf: add support for IPv6 proxy_ndp
Date: Fri, 20 Dec 2013 11:05:54 +0100
Message-ID: <52B41682.7050908@6wind.com>
References: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net> <20131217223714.325c0e78@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:39082 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756618Ab3LTKF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 05:05:58 -0500
Received: by mail-we0-f173.google.com with SMTP id u57so2231064wes.18
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 02:05:56 -0800 (PST)
In-Reply-To: <20131217223714.325c0e78@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/12/2013 07:37, Stephen Hemminger a =E9crit :
> Need to be able to see changes to proxy NDP status on a per
> interface basis via netlink (analog to proxy_arp).
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
