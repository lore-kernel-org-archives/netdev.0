From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: Kernel panic nf_nat_setup_info+0x5b3/0x6e0
Date: Thu, 31 Mar 2011 18:03:42 +0400
Message-ID: <586191301580222@web107.yandex.ru>
References: <118081298480841@web25.yandex.ru> <4D6E2BEB.50805@trash.net>
 <AANLkTikkz23221ZSiat8N5tnE_bkHN=1EUNQTDdnC30L@mail.gmail.com>
 <124481299095426@web67.yandex.ru> <AANLkTik87dd0=CqcMOcwKN-Hx7W6KD7A36DUhGAzLddr@mail.gmail.com> <AANLkTi=v_Ckn00N=b2R2pW7jb3BmyyWPSkeCYRxBW0CW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=v_Ckn00N=b2R2pW7jb3BmyyWPSkeCYRxBW0CW@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



26.03.2011, 16:44, "Changli Gao" <xiaosuo@gmail.com>:
> On Thu, Mar 3, 2011 at 3:33 PM, Changli Gao <xiaosuo@gmail.com>; wrot=
e:
>
>> =9APlease try the patch attached and test if the problem is solved o=
r not. Thanks.
>
> Any feedback? Thanks.
>

Seems that patch is fine.

https://bugzilla.kernel.org/show_bug.cgi?id=3D21512

--=20
wbr, Oleg.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
