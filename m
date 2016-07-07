From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [iproute PATCH 0/2] Netns performance improvements
Date: Thu, 7 Jul 2016 14:59:48 +0200
Message-ID: <577E5244.8030601@6wind.com>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
 <87twg4ywjz.fsf@x220.int.ebiederm.org> <20160705205103.GE620@orbyte.nwl.cc>
 <87h9c259ip.fsf@x220.int.ebiederm.org> <20160707111718.GL620@orbyte.nwl.cc>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Phil Sutter <phil@nwl.cc>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38850 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521AbcGGM7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 08:59:52 -0400
Received: by mail-wm0-f43.google.com with SMTP id n127so15384423wme.1
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 05:59:51 -0700 (PDT)
In-Reply-To: <20160707111718.GL620@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/07/2016 13:17, Phil Sutter a =E9crit :
[snip]
> The issue came up during OpenStack Neutron testing, see this ticket f=
or
> reference:
>=20
> https://bugzilla.redhat.com/show_bug.cgi?id=3D1310795
Access to this ticket is not public :(
