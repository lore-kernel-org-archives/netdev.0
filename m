From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH] qed*: Fix build for !QED_RDMA
Date: Wed, 21 Jun 2017 13:52:38 +0000
Message-ID: <BLUPR0701MB20045B29390DD15330D86DE98DDA0@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170621104531.11071-1-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Mark Brown <broonie@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0079.outbound.protection.outlook.com ([104.47.42.79]:18720
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750999AbdFUNwl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 09:52:41 -0400
In-Reply-To: <20170621104531.11071-1-broonie@kernel.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> A stray semicolon was introduced by bbfcd1e8e1677b (qed*: Set rdma
> generic functions prefix), remove it.=09

Hi Mark,

Thanks, but I've already sent the same
http://marc.info/?l=3Dlinux-netdev&m=3D149802281509733&w=3D2

Thanks,
Yuval
