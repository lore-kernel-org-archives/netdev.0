From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] netconf: add proxy-arp support
Date: Fri, 13 Dec 2013 08:57:13 -0800
Message-ID: <20131213085713.3dcbf00c@nehalam.linuxnetplumber.net>
References: <20131212130650.52c7b267@nehalam.linuxnetplumber.net>
	<52AAC899.801@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:34798 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752431Ab3LMQ5R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 11:57:17 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so2809900pbb.32
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 08:57:17 -0800 (PST)
In-Reply-To: <52AAC899.801@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Dec 2013 09:43:05 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Le 12/12/2013 22:06, Stephen Hemminger a =E9crit :
> > Add support to netconf to show changes to proxy-arp status on a per
> > interface basis via netlink in a manner similar to forwarding
> > and reverse path state.
> >
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>=20
> I suppose that the iproute2 patch will follow.
> Do you plan to add PROXY_NDP too?

Yes iproute2 patch is waiting to see if kernel part is ok.
Haven't looked at NDP yet.
