From: "Boris B. Zhmurov" <zhmurov@yandex-team.ru>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Mon, 10 Jun 2013 22:29:54 +0400
Message-ID: <51B61B22.2010604@yandex-team.ru>
References: <1370229169.24311.119.camel@edumazet-glaptop> <20130602.202703.1059637861388689182.davem@davemloft.net> <20130603034254.GC29614@linux.vnet.ibm.com> <20130602.204915.334823676645400072.davem@davemloft.net>
Reply-To: zhmurov@yandex-team.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, eric.dumazet@gmail.com,
	klamm@yandex-team.ru, brouer@redhat.com, dipankar@in.ibm.com,
	zhmurov@yandex-team.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, David.Laight@ACULAB.COM,
	stable@vger.kernel.org, gregkh@linuxfoundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130602.204915.334823676645400072.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/03/2013 07:49 AM, David Miller wrote:


>>>> Well, whole discussion went on linux kernel, and you were the orig=
inal
>>>> committer of this patch five years ago.
>>>>
>>>> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/com=
mit/?id=3Dbbaffaca4810de1a25e32ecaf836eeaacc7a3d11
>>>>
>>>> So please Paul or David make sure the patch goes in.
>>>>
>>>> My only concern is that Paul seems quite busy these days.
>>>
>>> Ok I can take it then, no problem.
>>
>> Or if you would like to take it:
>>
>> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>=20
> Let's end this deadlock by me taking it :-)


Hello David,

Do you think, this patch is "stable material" and should be included in
3.0-stable and 3.4-stable trees? Thanks.

--=20
Boris B. Zhmurov
Yandex.Search SRE Team
*************
=D1=82.: +7 (495) 739-70-00 ext.7160
http://yandex.ru
*************
