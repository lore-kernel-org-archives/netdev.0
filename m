From: =?UTF-8?Q?=CE=86=CE=BB=CE=BA=CE=B7=CF=82_?=
	 =?UTF-8?Q?=CE=93=CE=B5=CF=89=CF=81=CE=B3=CF=8C=CF=80=CE=BF=CF=85=CE=BB?=
	 =?UTF-8?Q?=CE=BF=CF=82?= <alkisg@gmail.com>
Subject: Re: r8169 - disable flow-control?
Date: Thu, 05 Mar 2009 23:29:07 +0200
Message-ID: <1236288547.10409.23.camel@alkisg>
References: <1236281743.10409.17.camel@alkisg>
	 <1236287329.3202.7.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:62499 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbZCEV3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:29:12 -0500
Received: by fxm24 with SMTP id 24so127611fxm.37
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2009 13:29:09 -0800 (PST)
In-Reply-To: <1236287329.3202.7.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=CE=A3=CF=84=CE=B9=CF=82 05-03-2009, =CE=B7=CE=BC=CE=AD=CF=81=CE=B1 =CE=
=A0=CE=B5=CE=BC, =CE=BA=CE=B1=CE=B9 =CF=8E=CF=81=CE=B1 21:08 +0000, =CE=
=BF/=CE=B7 Ben Hutchings
=CE=AD=CE=B3=CF=81=CE=B1=CF=88=CE=B5:
> Generally you should be able to control this using ethtool, not a mod=
ule
> parameter.  However r8169 does not implement this operation yet.

Thanks - I just thought that supporting a module parameter (like e1000'=
s
=46lowControl=3D2) would be a small thing to ask, as opposed to support=
ing
ethtool.

But of course if ethtool is to be eventually supported by r8169, then
adding a parameter would be redundant.


Kind regards,
Alkis Georgopoulos

