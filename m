From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v7 4/6] vxlan: add ipv6 support
Date: Tue, 30 Apr 2013 17:25:56 +0800
Message-ID: <1367313956.3216.18.camel@cr0>
References: <1367311395-15891-1-git-send-email-amwang@redhat.com>
	 <1367311395-15891-5-git-send-email-amwang@redhat.com>
	 <87r4hscr7s.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759818Ab3D3J0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 05:26:23 -0400
In-Reply-To: <87r4hscr7s.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-30 at 11:17 +0200, Bj=C3=B8rn Mork wrote:
> Please take your time to clean up your todo-list and *test* the resul=
t
> with different runtime and buildtime settings. There is no need to ru=
sh
> this, and people may get tired of looking at the same shortcomings ov=
er
> and over again.
>=20

So, why do you expect it is perfect?

It is extremely normal that a new feature is not perfect initially, and
takes more time to make it perfect. If you need a real example, netlink
mmap is exactly one, the initial version merged into net-next even
doesn't compile for some case.

And, why do you want to rely on me to fix them all?

I am *not* at all an expert on IPv6. If this patchset could be merged
early, many other IPv6 expert can help me to fix the rest issues.
