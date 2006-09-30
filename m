From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 0/3] myri10ge Large Receive Offload
Date: Sat, 30 Sep 2006 16:01:27 +0200
Message-ID: <451E78B7.6060803@myri.com>
References: <451B0541.1030208@myri.com> <451B4F44.60204@garzik.org> <451D9B4C.3020008@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:22711 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1750975AbWI3OBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 10:01:47 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <451D9B4C.3020008@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin a =E9crit :
> Could we get patch #1 merged anyway (page-based skb allocation)?
>  =20

Oops, actually, one hunk has to be dropped (it reverts const'ification
of ethtool_ops by mistake). If it is ok to merge the patch apart from
this hunk,  will resend an updated patch.

Brice

