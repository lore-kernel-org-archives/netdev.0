From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211_hwsim: Added vendor echo command
Date: Sat, 25 Jun 2016 21:57:48 +0200
Message-ID: <1466884668.3492.0.camel@sipsolutions.net>
References: <1466756034-5485-1-git-send-email-erik.stromdahl@gmail.com>
 <20160624204759.GA15514@w1.fi>
 <576EAC61.1050900@gmail.com>
	 <20160625183209.GA3992@w1.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Jouni Malinen <j@w1.fi>, Erik Stromdahl <erik.stromdahl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59051 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751623AbcFYT5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2016 15:57:54 -0400
In-Reply-To: <20160625183209.GA3992@w1.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-06-25 at 21:32 +0300, Jouni Malinen wrote:
>=C2=A0
> All you need to do is to prepare a hostap.git contribution that
> requests a new subcommand/attribute to be assigned and once that gets
> applied to the hostap.git master branch, the values have been
> assigned and can be used for whatever purpose they were assigned,
> e.g., in mac80211_hwsim.
>=20

Assuming, of course, that there's actually a point in the original
patch. I haven't quite figured out any reason to actually have this
facility.

johannes
