From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] net: mac80211: tx.c: be sure of 'sdata->vif.type' must
 be NL80211_IFTYPE_AP when be in NL80211_IFTYPE_AP case
Date: Wed, 04 Dec 2013 09:04:41 +0100
Message-ID: <1386144281.4284.0.camel@jlt4.sipsolutions.net>
References: <528AEFB7.4060301@gmail.com>
	  <20131125011938.GB18921@codeaurora.org> <5292B845.3010404@gmail.com>
	  <5292B8A0.7020409@gmail.com> <5294255E.7040105@gmail.com>
	  <52957ADA.2080704@gmail.com>
	  (sfid-20131127_055211_558798_A7DF5684) <1385739487.8656.1.camel@jlt4.sipsolutions.net>
	  <5299D306.7070701@gmail.com>
	  (sfid-20131130_125901_519610_EDA4068E) <1385816013.4327.1.camel@jlt4.sipsolutions.net>
	  <5299ED38.4090509@gmail.com> <5299EFDD.6060405@gmail.com>
	  (sfid-20131130_150205_984535_068F14A9) <1385842134.6108.4.camel@jlt4.sipsolutions.net>
	  <1385843940.2664.4.camel@joe-AO722>
	  <1385890523.4171.1.camel@jlt4.sipsolutions.net>
	  <1385937499.2664.21.camel@joe-AO722>
	 <1385995738.20277.4.camel@jlt4.sipsolutions.net>
	 <529E8F90.1020205@gmail.com> (sfid-20131204_031032_173575_B927B340)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	rkuo <rkuo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <529E8F90.1020205-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (sfid-20131204_031032_173575_B927B340)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-12-04 at 10:12 +0800, Chen Gang wrote:

> It is really not urgent, and for keeping quality, it is necessary to
> spend suitable time resource (e.g 1 hour or more) to  make, review and
> test this kind of patch carefully by oneself.
> 
> So could you please help improve it when you have suitable related time
> resources?

No. Who are you to suggest what I need to work on?

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
