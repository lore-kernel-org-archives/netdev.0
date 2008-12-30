From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: cls_cgroup: clean up for cgroup part
Date: Tue, 30 Dec 2008 11:43:56 +0800
Message-ID: <495998FC.8050503@cn.fujitsu.com>
References: <20081229.190724.20711084.davem@davemloft.net> <20081229.193836.123306072.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59740 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751769AbYL3DpD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 22:45:03 -0500
In-Reply-To: <20081229.193836.123306072.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Actually, the tree doesn't even build after applying this
> patch.
>=20
> How did you test this?
>=20
> net/sched/cls_cgroup.c: In function =E2=80=98write_classid=E2=80=99:
> net/sched/cls_cgroup.c:68: error: implicit declaration of function =E2=
=80=98net_cls_state=E2=80=99
> net/sched/cls_cgroup.c:68: error: invalid type argument of =E2=80=98-=
>=E2=80=99
>=20
> I made the obvious fixup to this change, but...
>=20
> Come on, build test your changes. :-(
>=20

Ouch, sorry.. I did a fixup when I was making those patches,
but forgot to update the patch..

