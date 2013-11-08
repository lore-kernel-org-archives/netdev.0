From: Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 00/16] wl1251 patches from linux-n900 tree
Date: Fri, 8 Nov 2013 08:20:07 -0600
Message-ID: <CAMP44s1ADLHagfPa8kmx_wSyqvLf7pcN_UuOqoPShYx2HPUQXA@mail.gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless Mailing List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	freemangordon-uiMcrn6V0Vs@public.gmane.org, aaro.koskinen-X3B1VOXEql0@public.gmane.org,
	Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, sre-GFxCN5SEZAc@public.gmane.org,
	joni.lapilainen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1382819655-30430-1-git-send-email-pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 26, 2013 at 3:33 PM, Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=
 wrote:
> Hello, I'm sending wl1251 patches from linux-n900 tree [1] for commen=
ts. More
> patches come from David's monitor & packet injection work. Patches ar=
e tested
> with 3.12 rc5 kernel on Nokia N900.
>
> [1] - https://gitorious.org/linux-n900/linux-n900

How did you test these patches? I get a panic loop immediately after I
bring the interface loop in monitor mode (v3.12).

--=20
=46elipe Contreras
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
