From: Kenneth Lee <liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: Re: =?utf-8?B?562U5aSNOiBbUEFUQ0ggMS81XSBu?= =?utf-8?Q?et=3A_ad?=
 =?utf-8?Q?d?= Hisilicon Network Subsystem support (config and documents)
Date: Thu, 27 Aug 2015 17:50:35 +0800
Message-ID: <20150827095035.GB26498@Turing-Arch-b>
References: <1439548222-231611-1-git-send-email-liguozhu@hisilicon.com>
 <1536926.jEJjsM70Lj@wuerfel>
 <161EFA05D917D0419F95C4CAEEF86C1094E95FAA@SZXEMA504-MBS.china.huawei.com>
 <2543796.7JthO5WCfI@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"pawel.moll-5wv7dgnIgG8@public.gmane.org" <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	"ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org" <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	"catalin.marinas-5wv7dgnIgG8@public.gmane.org" <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	"will.deacon-5wv7dgnIgG8@public.gmane.org" <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linuxarm <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	"paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org" <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2543796.7JthO5WCfI@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 21, 2015 at 04:00:35PM +0200, Arnd Bergmann wrote:
> Date: Fri, 21 Aug 2015 16:00:35 +0200
> From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> To: "Liguozhu (Kenneth)" <liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> CC: "mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
>  "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
>  "pawel.moll-5wv7dgnIgG8@public.gmane.org" <pawel.moll-5wv7dgnIgG8@public.gmane.org>, "ijc+devicetree@hellion.o=
rg.uk"
>  <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, "catalin.marinas-5wv7dgnIgG8@public.gmane.org"
>  <catalin.marinas-5wv7dgnIgG8@public.gmane.org>, "will.deacon-5wv7dgnIgG8@public.gmane.org" <will.deacon-AbSShOkvfpQ@public.gmane.org=
m>,
>  "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux=
arm
>  <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, "paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org"
>  <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>, "robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt@kernel=
=2Eorg>,
>  "galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, "zhangfei.gao@linaro.=
org"
>  <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
>  <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org=
>,
>  "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
>  <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
> Subject: Re: =E7=AD=94=E5=A4=8D: [PATCH 1/5] net: add Hisilicon Netwo=
rk Subsystem
>  support (config and documents)
> User-Agent: KMail/4.11.5 (Linux/3.16.0-10-generic; KDE/4.11.5; x86_64=
; ; )
> Message-ID: <2543796.7JthO5WCfI@wuerfel>
>=20
> On Monday 17 August 2015 01:28:07 Liguozhu wrote:
> > Thanks, Arnd.=20
> >=20
> > Regarding the ae-name: it is the name of the Acceleration Engine. I=
t is provided
> > by the BIOS according to the position and the feature enabled of th=
e IP.
> > So "soc0" means it is on SoC No. 0, while "n4" means it is running =
on=20
> >"Non-dsaf mode 4". Ideally, we should setup the rule to name it. But=
 as I
> > said in the patchset, the IP is original designed for a bare metal =
solution,
> > it is worthless to export all modes and we are planning to add more=
 mode
> > for Linux itself in the IP in future version. So I think the better=
 way is
> > to leave it as a "name" but add more meaning in the future.
>=20
> The name property is a bit awkward. The position is normally implied =
by
> the location of the parent device in the DT, so you should not need t=
hat
> at all and instead derive it elsewhere. You can also add strings to t=
he
> compatible property instead of this, to signify differences in the pr=
ogramming
> that are based on how the IP block is used.
> =20
> > Regarding the ae-opts: it is the initial value for the AE's runtime=
 options,
> > Currently, we have only "port number" (there are 6XGE+2GE port for =
a DSAF AE)
> > as option. But for future version, we will add other options such a=
s "enable
> > Spanning Tree Protocol algorithm)" and so on.=20
>=20
> I think these can easily be converted into an index property and bool=
ean
> flags (present if true, absent otherwise) for additional features.
> =20
> > Should I add these background to somewhere?
>=20
> The binding document needs to list all supported configurations, if y=
ou
> have a string property, describe specifically what strings are allowe=
d
> and what they mean, but better try to avoid strings altogether.
>=20
> 	Arnd
> _______________________________________________
> linuxarm mailing list
> linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
> http://rnd-openeuler.huawei.com/mailman/listinfo/linuxarm

Dear Arnd,

We are working on the new PatchSet. I describe the new design here so i=
n case
you can tell us if we make something wrong.

So now we will keep some attributes in enthernet node like this:

	ethernet@0{
		compatible =3D "hisilicon,hns-nic";
		ae-name =3D "dsaf1";
		port-id =3D <0>;
	};

ae-name is simply a name referring to the name of dsa_name in SAF node.

port-id is the index of port provided by DSAF (the accelerator). DSAF c=
an
connect to 8 PHYs. Port 0 to 1 are both used for adminstration purpose.=
 They
are called debug ports.=20

The remaining 6 PHYs are taken according to the mode of DSAF.

In NIC mode of DSAF, all 6 PHYs are taken as ethernet ports to the CPU.=
 The
port-id can be 2 to 7. Here is the diagram:

            +-----+---------------+
            |            CPU      |
            +-+-+-+---+-+-+-+-+-+-+
              | |     | | | | | |
	     debug       service=20
             port         port
	     (0,1)       (2-7)

In Switch mode of DSAF, all 6 PHYs are taken as physical ports connect =
to a
LAN Switch while the CPU side assume itself have one single NIC connect=
 to
this switch. In this case, the port-id will be 2 only.

            +-----+---------------+
            |            CPU      |
            +-+-+-+---+-+-+-+-+-+-+
              | |         | service port(2)
	     debug   +------------+
             port    |   switch   |
             (0,1)   +-+-+-+-+-+-++
                       | | | | | |
                        external
			 port


--=20
			-Kenneth(Hisilicon)
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
