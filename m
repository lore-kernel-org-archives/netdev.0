From: Adrian Chadd <adrian-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>
Subject: Re: [ath9k-devel] ath9k channel switch
Date: Wed, 8 Apr 2015 12:19:22 -0700
Message-ID: <CAJ-VmokVe0dO1kHh8u0ok3G6V70cj-i8qeKHyMRpnWeDEK4w9Q@mail.gmail.com>
References: <CAGrUaU24vCH6+GpAtBCNiGwdT4_-FNNLDq=_s5zhSPBOp8bbmg@mail.gmail.com>
	<21764.61660.411242.223378@gargle.gargle.HOWL>
	<CAGrUaU1D_tO9+HrH_mEa0U13xTCuOijyvcn2_mi8cUgkkPeOuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sujith Manoharan <sujith-TPRpbcbO+rZAfugRpC6u6w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ath9k-devel <ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ath9k-devel <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
To: Saurabh Pal <saurabh6321-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGrUaU1D_tO9+HrH_mEa0U13xTCuOijyvcn2_mi8cUgkkPeOuw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

You can do a fast channel switch under very specific conditions. It
includes but isn't limited to being on the same band (ie, no fast cc
between 2/5ghz.)


-adrian
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
