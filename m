From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v3 0/3] e1000e,igb,ixgbe: add registers etc. printout code
	just before resetting adapters
Date: Mon, 19 Apr 2010 15:44:17 -0700
Message-ID: <s2q9929d2391004191544p1b9e51b5q9a425a44927e1321@mail.gmail.com>
References: <4BCC3C9B.3000901@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	chavey@google.com
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f171.google.com ([209.85.210.171]:63009 "EHLO
	mail-yx0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab0DSWoV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 18:44:21 -0400
Received: by yxe1 with SMTP id 1so3272892yxe.33
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 15:44:20 -0700 (PDT)
In-Reply-To: <4BCC3C9B.3000901@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/4/19 Taku Izumi <izumi.taku@jp.fujitsu.com>:
> Hi Jeff,
>
> This patchset is the update version of "register etc. printout code" =
patch.
> The old ones are
> =C2=A0http://kerneltrap.org/mailarchive/linux-netdev/2010/1/7/6265865
> =C2=A0http://kerneltrap.org/mailarchive/linux-netdev/2010/1/22/626717=
6
>
> v2 -> v3:
> =C2=A0- avoid modifying headers
> =C2=A0- delete "dump_flag" module parameter and use msglvl instead.
>
> =C2=A0To enable the printout, it is necessary to specify msglvl like =
the following.
> =C2=A0# =C2=A0 =C2=A0 =C2=A0 ethtool -s eth0 msglvl 0x2003
>
> Best regards,
> Taku Izumi
>

Thank you Taku.  I have added the series of patches to my queue of
patches destined for net-next.

--=20
Cheers,
Jeff
