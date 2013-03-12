From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: atl1c issues on 3.8.2
Date: Tue, 12 Mar 2013 16:45:44 +0100
Message-ID: <1363103144.13690.12.camel@edumazet-glaptop>
References: <20130312161753.281681f2@milhouse>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>
To: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:47274 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932356Ab3CLPps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 11:45:48 -0400
Received: by mail-ee0-f49.google.com with SMTP id d41so2782701eek.22
        for <netdev@vger.kernel.org>; Tue, 12 Mar 2013 08:45:47 -0700 (PDT)
In-Reply-To: <20130312161753.281681f2@milhouse>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-12 at 16:17 +0100, Michael B=C3=BCsch wrote:
> Hi,
>=20
> Starting with 3.8.x scp stalls the atl1c based interface on my Asus E=
eepc 1011px.
> iperf (for example) does not do that. But after scp stalled the inter=
face,
> iperf transfers fail, too.

I am pretty sure David stable list contains the needed fix=20

http://patchwork.ozlabs.org/bundle/davem/stable/?state=3D*

Should be included in 3.8.3=20

Detail : http://patchwork.ozlabs.org/patch/221737/
