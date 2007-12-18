From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: iwlwifi: fix-up merge fall-out after namespace separation
Date: Mon, 17 Dec 2007 22:04:23 -0500
Message-ID: <476738B7.7030104@garzik.org>
References: <20071216043419.GF3096@tuxdriver.com> <47670514.4030204@garzik.org> <476708EF.10403@garzik.org> <20071218022540.GB3640@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071218022540.GB3640-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
>> drivers/net/wireless/iwlwifi/iwl3945-base.c: In function=20
>> =E2=80=98iwl3945_alive_start=E2=80=99:
>> drivers/net/wireless/iwlwifi/iwl3945-base.c:6285: error: implicit=20
>> declaration of function =E2=80=98iwl_rate_control_unregister=E2=80=99
>> make[4]: *** [drivers/net/wireless/iwlwifi/iwl3945-base.o] Error 1
>> make[3]: *** [drivers/net/wireless/iwlwifi] Error 2
>> make[2]: *** [drivers/net/wireless] Error 2
>> make[1]: *** [drivers/net] Error 2
>> make: *** [drivers] Error 2
>=20
> Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

applied, thanks
