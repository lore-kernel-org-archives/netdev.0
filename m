From: Holger Schurig <holgerschurig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [ath5k-devel] [PATCH 09/28] Remove ATHEROS_AR231X
Date: Wed, 18 Jun 2014 15:15:44 +0200
Message-ID: <CAOpc7mE+829tBdy5atjtoJnGWDAnAHT_U0swXCuS3n_DMave1Q@mail.gmail.com>
References: <1391971686-9517-1-git-send-email-richard@nod.at>
	<1391971686-9517-10-git-send-email-richard@nod.at>
	<52F7D480.1050106@hauke-m.de>
	<52F7DF21.70207@nod.at>
	<CAHNKnsS7Mv4ZhBWZa53go9L9nZimJ7_FG5HFJ9C3kkGMAEz-mA@mail.gmail.com>
	<52F8C373.9060108@rempel-privat.de>
	<CAHNKnsQF5Hdf3JT91moPraRQzn4kMpdD2NSiJ7b30wQhS1W4MA@mail.gmail.com>
	<CAGVrzcYnECx5Q=i+m6qZn29y4JALDpw5SWoUNP-S6HgPR3_ygQ@mail.gmail.com>
	<CAHNKnsRACSo=DfOyiHxqV3acv_wfZmz4tMnYAW0wo4OCibwdfA@mail.gmail.com>
	<CAHNKnsRQp7WLSJNAXEYPTd=qs1DquOfNgKtHES-Utvcy1=FEgQ@mail.gmail.com>
	<20140213201421.GJ22203@tuxdriver.com>
	<1397581703.8212.5.camel@x220>
	<CAHNKnsQQ42-XnXrubHAy4PF3H2ynbGDdSMP7MvDS_1aRozYF=A@mail.gmail.com>
	<1403087119.1984.93.camel@x220>
	<CAHNKnsSfaT7xC5_wv=TrGLEQ2pjC91Q1XG891_n64OuR0fA9Jg@mail.gmail.com>
	<1403091974.1984.102.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sergey Ryazanov <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	List <openwrt-devel-ZwoEplunGu0+xA9t4nZiwti2O/JbrIOy@public.gmane.org>,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Richard-juf53994utBLZpfksSYvnA@public.gmane.org,
	"Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>, open-5/S+JYg5SzeELgA04lAiVw@public.gmane.org,
	Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, ath5k-devel-juf53994utBLZpfksSYvnA@public.gmane.org,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Oleksij Rempel <linux-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>,
	Hauke-juf53994utBLZpfksSYvnA@public.gmane.org, Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>,
	"list-5/S+JYg5SzeELgA04lAiVw@public.gmane.org:NETWORKING DRIVERS" <list-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>,
	Jonathan Bither <jonbither-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"list-5/S+JYg5SzeELgA04lAiVw@public.gmane.org:NETWORKING DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	OpenWrt-juf53994utBLZpfksSYvnA@public.gmane.org,
	"antonynpavlov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <antonynpavlov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1403091974.1984.102.camel@x220>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Having this conversation every rc1 is getting a bit silly.

Hmm, wouldn't the obvious thing than to add the driver in it's current
form into staging?  Is it well-separated from the rest of  Atheros
WLAN drivers ?
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
