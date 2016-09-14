From: "Amrani, Ram" <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC 02/11] Add RoCE driver framework
Date: Wed, 14 Sep 2016 07:30:23 +0000
Message-ID: <SN1PR07MB2207EA31C3D872AF50CC9B75F8F10@SN1PR07MB2207.namprd07.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
 <018901d20dcd$98d0c040$ca7240c0$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <018901d20dcd$98d0c040$ca7240c0$@opengridcomputing.com>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > +	if ((event !=3D NETDEV_CHANGENAME) && (event !=3D
> > NETDEV_CHANGEADDR))
>=20
> nit: You don't really need the extra parens here.
>=20
Sure, thanks. Will remove.
=20

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
