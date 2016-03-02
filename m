From: =?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?= <bro.devel@gmail.com>
Subject: Re: [PATCH v5 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Wed, 2 Mar 2016 23:33:49 +0100
Message-ID: <56D76A4D.6030502@gmail.com>
References: <1456348375-24684-1-git-send-email-bro.devel+kernel@gmail.com>
 <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
 <1456348375-24684-3-git-send-email-bro.devel+kernel@gmail.com>
 <20160302.145204.1321971452365441235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ycheng@google.com, eric.dumazet@gmail.com,
	ncardwell@google.com, apetlund@simula.no, griff@simula.no,
	paalh@simula.no, jonassm@ifi.uio.no, kristian.evensen@gmail.com,
	kennetkl@ifi.uio.no
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34272 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756005AbcCBWdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 17:33:52 -0500
Received: by mail-wm0-f65.google.com with SMTP id p65so1113896wmp.1
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 14:33:51 -0800 (PST)
In-Reply-To: <20160302.145204.1321971452365441235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2016 08:52 PM, David Miller wrote:
> From: "Bendik R=F8nning Opstad" <bro.devel@gmail.com>
> Date: Wed, 24 Feb 2016 22:12:55 +0100
>=20
>> +/* tcp_rdb.c */
>> +void rdb_ack_event(struct sock *sk, u32 flags);
>=20
> Please name globally visible symbols with a prefix of "tcp_*", thanks=
=2E

Yes, of course. I will fix that for the next version.

Thanks.

Bendik
