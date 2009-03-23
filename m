From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH] net/bridge: use the maximum hard_header_len of ports for
	bridging device
Date: Mon, 23 Mar 2009 16:15:34 +0800
Message-ID: <2a27d3730903230115r52fb73f0q87c496eda19ba88c@mail.gmail.com>
References: <1237539869-30721-1-git-send-email-leoli@freescale.com>
	 <2a27d3730903230059s5f6aa886k30515bd6429a1e71@mail.gmail.com>
	 <20090323.010247.82335962.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:52242 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757402AbZCWIPi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 04:15:38 -0400
Received: by rv-out-0506.google.com with SMTP id g37so973218rvb.5
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 01:15:34 -0700 (PDT)
In-Reply-To: <20090323.010247.82335962.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2009 at 4:02 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Li Yang <leoli@freescale.com>
> Date: Mon, 23 Mar 2009 15:59:24 +0800
>
>> Any comment about this? =C2=A0Is it possible to be included in 2.6.2=
9?
>
> Patience please? =C2=A0I reviewed and applied more than 80 patches
> yesterday, maybe I'll get to your's after I recover from that.
>
> Your patch is in the queue at:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0http://patchwork.ozlabs.org/project/netdev=
/list/
>
> You can monitor it's state and what's happening to it here.

Good to know it is being tracked.  After you have applied all those
patches, I was wondering if this one failed to get your attention.
Thanks.

- Leo
