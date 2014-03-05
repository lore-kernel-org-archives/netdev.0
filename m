From: Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCHv3 net-next 00/31] Misc. fixes for cxgb4 and iw_cxgb4
Date: Wed, 5 Mar 2014 12:51:49 -0800
Message-ID: <165B3A81-646E-4AEB-A1CC-D7F3C255A870@chelsio.com>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com> <20140304.132226.75524344104026791.davem@davemloft.net> <20140305053024.GA23862@hariprasad-pc> <9E6E5D92-7F25-49A3-BEB5-424CCE2F725D@chelsio.com> <CAJZOPZL05TY6qSdBDoS6aCj=_uepkZTX5+fVvnHTsCsKKMqgSQ@mail.gmail.com> <F598A76E-C6C1-4183-B4B9-DF78FD1FE73A@chelsio.com> <CAJZOPZL6U7csoTvF8wzJBK+Whknv4dqNbkO8nC=LrXoUMXhoUQ@mail.gmail.com> <DB7B3A5C-9674-44C2-8AA4-2C468F09DFF5@chelsio.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hariprasad S <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <DB7B3A5C-9674-44C2-8AA4-2C468F09DFF5-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Mar 5, 2014, at 11:59 AM, Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org> wrote:

>=20
> On Mar 5, 2014, at 11:52 AM, Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>=20
>> On Wed, Mar 5, 2014 at 9:46 PM, Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org> wr=
ote:
>>=20
>> are you referring to constants defined in
>> drivers/net/ethernet/chelsio/cxgb4/t4_hw.h or other/more headers?
>=20
>  t4_regs.h.  Strangely, when we submitted the driver, the very simila=
r symbolic constant formats in t4_msg.h and t4fw_api.h weren=92t target=
ed; just the ones in t4_regs.h.

  By the way, please don=92t take this as in any way advocating that th=
e symbolic constants in t4_msg.h and t4fw_api.h should also be changed =
in a way which is incompatible with out out-of-kernel development tree =
=97 our lives are hard enough already with the changes symbolic constan=
ts in t4_regs.h! :-)

Casey--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
