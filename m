From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 1/3] netconf: rename PROXY_ARP to NEIGH_PROXY
Date: Fri, 20 Dec 2013 11:02:12 +0100
Message-ID: <52B415A4.7040408@6wind.com>
References: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:52874 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755298Ab3LTKCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 05:02:15 -0500
Received: by mail-wg0-f44.google.com with SMTP id a1so2230044wgh.35
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 02:02:14 -0800 (PST)
In-Reply-To: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/12/2013 07:35, Stephen Hemminger a =E9crit :
> Use same field for both IPv4 (proxy_arp) and IPv6 (proxy_ndp)
> so fix it before API is set to be a common name
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
