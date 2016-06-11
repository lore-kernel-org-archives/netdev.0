From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: mac80211-next 2016-06-09
Date: Fri, 10 Jun 2016 23:16:04 -0700 (PDT)
Message-ID: <20160610.231604.604019579709781335.davem@davemloft.net>
References: <1465477466-23756-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbcFKGQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 02:16:06 -0400
In-Reply-To: <1465477466-23756-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Johannes Berg <johannes@sipsolutions.net>
Date: Thu,  9 Jun 2016 15:04:25 +0200

> Here's my first set of changes for -next. The only exciting part are =
the
> changes from Micha=A9=A9 to integrate FQ/codel into mac80211's softwa=
re queues
> to improve cross-station latency and finally solve much of the latenc=
y
> issues so many people have spent so much time talking about, but neve=
r
> actually working on fixing until he did :)
>=20
> Can I ask you to pull net into net-next, preferably before merging th=
is?
> I have a patch that is unsafe without a fix that I submitted through
> mac80211 previously (last time, not the pull request a few minutes ag=
o),
> and I'd prefer not to have that in our -next trees without the fix. I=
f
> you merge net into net-next before this pull request I can fast-forwa=
rd
> mac80211-next to this merge later.
>=20
> Let me know if there's any problem.

Looks good, pulled, thanks!
