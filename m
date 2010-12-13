From: Zimny Lech <napohybelskurwysynom2010@gmail.com>
Subject: Re: linux-next: Tree for December 10
Date: Mon, 13 Dec 2010 20:04:26 +0100
Message-ID: <AANLkTikSjXT6xxKyamvE8YEygfpakdDMFt2F1rnkytfN@mail.gmail.com>
References: <20101210135746.0cf6cbcd.sfr@canb.auug.org.au>
	<AANLkTinXT6jyr9C=LJA9Y_5v3sWN1fDHF9NRsTLHVXuF@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinXT6jyr9C=LJA9Y_5v3sWN1fDHF9NRsTLHVXuF@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, this should be reported for next-20101213

W dniu 13 grudnia 2010 20:02 u=BFytkownik Zimny Lech
<napohybelskurwysynom2010@gmail.com> napisa=B3:
> Ave,
>
> 2010/12/10 Stephen Rothwell <sfr@canb.auug.org.au>:
>> Hi all,
>>
>> Changes since 20101209:
>>
>
> WARNING: modpost: Found 14 section mismatch(es).
> To see full details build your kernel with:
> 'make CONFIG_DEBUG_SECTION_MISMATCH=3Dy'
> =A0GEN =A0 =A0 .version
> =A0CHK =A0 =A0 include/generated/compile.h
> =A0UPD =A0 =A0 include/generated/compile.h
> =A0CC =A0 =A0 =A0init/version.o
> =A0LD =A0 =A0 =A0init/built-in.o
> =A0LD =A0 =A0 =A0.tmp_vmlinux1
> arch/x86/built-in.o: In function `kvm_smp_prepare_boot_cpu':
> kvm.c:(.init.text+0xf446): undefined reference to `kvm_register_clock=
'
> drivers/built-in.o: In function `generate_netlink_event':
> (.text+0x1087ee): undefined reference to `__alloc_skb'
> drivers/built-in.o: In function `generate_netlink_event':
> (.text+0x108897): undefined reference to `skb_put'
> drivers/built-in.o: In function `generate_netlink_event':
> (.text+0x108930): undefined reference to `kfree_skb'
> drivers/built-in.o: In function `generate_netlink_event':
> (.text+0x108947): undefined reference to `nla_reserve'
> drivers/built-in.o: In function `generate_netlink_event':
> (.text+0x108990): undefined reference to `kfree_skb'
> drivers/built-in.o: In function `generate_netlink_event':
> (.text+0x1089e9): undefined reference to `kfree_skb'
> drivers/built-in.o: In function `generate_netlink_event':
> (.text+0x1089f8): undefined reference to `init_net'
> drivers/built-in.o: In function `generate_netlink_event':
> (.text+0x108a0b): undefined reference to `netlink_broadcast'
> drivers/built-in.o: In function `thermal_init':
> thermal_sys.c:(.init.text+0xbd00): undefined reference to `genl_regis=
ter_family'
> thermal_sys.c:(.init.text+0xbd2f): undefined reference to
> `genl_register_mc_group'
> thermal_sys.c:(.init.text+0xbd57): undefined reference to
> `genl_unregister_family'
> drivers/built-in.o: In function `thermal_exit':
> thermal_sys.c:(.exit.text+0x154c): undefined reference to
> `genl_unregister_family'
> make[1]: *** [.tmp_vmlinux1] Error 1
> make: *** [sub-make] Error 2
>
>
> --
> Slawa!
> Zimny "Spie dziadu!" Lech z Wawelu
>
> Hej, tam!
> Wydar=B3em klejnot szans
> http://www.youtube.com/watch?v=3DVXWTlYzVFUA
>



--=20
Slawa!
Zimny "Spie dziadu!" Lech z Wawelu

Hej, tam!
Wydar=B3em klejnot szans
http://www.youtube.com/watch?v=3DVXWTlYzVFUA
