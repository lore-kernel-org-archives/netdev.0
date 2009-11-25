From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6] ixgbe: Fix TX stats accounting
Date: Wed, 25 Nov 2009 01:38:19 -0800
Message-ID: <9929d2390911250138n4855aebas151776df92388aea@mail.gmail.com>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
	 <Pine.WNT.4.64.0911231525180.10056@ppwaskie-MOBL2.amr.corp.intel.com>
	 <4B0B8F52.3010005@gmail.com> <1259053673.2631.30.camel@ppwaskie-mobl2>
	 <4B0BADA6.7080602@gmail.com> <1259057164.2631.36.camel@ppwaskie-mobl2>
	 <4B0BC56D.1000909@gmail.com> <4B0BDE3E.2020406@gmail.com>
	 <9929d2390911242338m6c4b322dod7a8af4c3c386d56@mail.gmail.com>
	 <4B0CF974.2070702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"robert@herjulf.net" <robert@herjulf.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:39440 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758508AbZKYJiN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 04:38:13 -0500
Received: by pzk1 with SMTP id 1so5483502pzk.33
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2009 01:38:19 -0800 (PST)
In-Reply-To: <4B0CF974.2070702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 25, 2009 at 01:31, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> Jeff Kirsher a =C3=A9crit :
>>
>> Thanks Eric. =C2=A0I have added the patch to my tree for testing and=
 review.
>>
>
> Thanks Jeff, a similar problem on RX stats should also be addressed.
>
> Is your tree public ?
>

Unfortunately we do not have a public tree at this time.  I do welcome
any patches you want to submit.

--=20
Cheers,
Jeff
