From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 0/2] tcp: Redundant Data Bundling (RDB)
Date: Sat, 24 Oct 2015 05:57:25 -0700
Message-ID: <1445691445.22974.200.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
	 <CAK6E8=eSYoxo6BLPh=jpmfudcRSJ3uT3YhZ0n-XP_dnxKCNH3A@mail.gmail.com>
	 <61F74109-9FDC-485A-978B-714B7AA27445@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neal Cardwell <ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Erik Kline <ek-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
	Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
	Daniel Lee <Longinus00-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Marcelo Ricardo Leitner <mleitner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linus =?ISO-8859-
To: Jonas Markussen <jonassm-6miFZF/5cTBuMpJDpNschA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <61F74109-9FDC-485A-978B-714B7AA27445-6miFZF/5cTBuMpJDpNschA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-10-24 at 08:00 +0000, Jonas Markussen wrote:

> Repacketization is only on retransmissions; RDB bundles previously se=
nt segments with the next =E2=80=9Cnormal=E2=80=9D transmission instead=
=2E=20
>=20
> This makes the flow recover the lost segment  before a retransmission=
 is triggered by an RTO or fast retransmit.

Thank you for this very high quality patch submission.

Please give us a few days for proper evaluation.

Thanks !
