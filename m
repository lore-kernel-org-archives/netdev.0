From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Driver-core: Always create class directories fixing
 the broken network drivers.
Date: Sun, 20 Jun 2010 13:33:48 +0200
Message-ID: <1277033628.3642.1.camel@jlt3.sipsolutions.net>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <1275914205.29978.10.camel@jlt3.sipsolutions.net>
	 <AANLkTilqB2sAyfBTLhYT_a2_TySGay4FFG6SGJUZ1o_4@mail.gmail.com>
	 <1275989260.3706.115.camel@jlt3.sipsolutions.net>
	 <AANLkTinMauFsJTKS3eT-pT44KQ8PSf3HJLS8CZIeHmxP@mail.gmail.com>
	 <1275990325.3706.116.camel@jlt3.sipsolutions.net>
	 <1275998127.1899.38.camel@yio.site>
	 <1275998603.3706.118.camel@jlt3.sipsolutions.net>
	 <AANLkTinev96yxFCFSdDdT89jjgYR4ChUCMU2-aSj8kkh@mail.gmail.com>
	 <1276005970.3706.132.camel@jlt3.sipsolutions.net>
	 <AANLkTikB0Amzi61JLxdY5HL-2s_nbYo3JH8vXooXzHdQ@mail.gmail.com>
	 <1276007174.3706.133.camel@jlt3.sipsolutions.net>
	 <AANLkTikNEzJHPrOUK6DKMoWvcblTBInaIhVbk96OtZxe@mail.gmail.com>
	 <1276009590.3706.135.camel@jlt3.sipsolutions.net>
	 <AANLkTimSqF4D4jPj-HzOjl1vxjf2T7YvlGdR6zcJZ9Pp@mail.gmail.com>
	 <1276014816.3706.137.camel@jlt3.sipsolutions.net>
	 <AANLkTilUd2Bp1h4SzlW5f5KevoRM-os_fQrivLHbZyKY@mail.gmail.com>
	 <1276250151.3640.11.camel@jlt3.sipsolutions.net>
	 <AANLkTil4IvOiDHnLwAaeseEPVgYp-EF5TK1HfHitY3-H@mail.gmail.com>
	 <1276507247.3926.13.camel@jlt3.sipsolutions.net>
	 <bug-16215-7251@https.bugzilla.kernel.org/>
	 <AANLkTin2sci1gSmwx-tjazYGFAcUNRKhJFI7Bt0KvVe3@mail.gmail.com>
	 <m139wiuswa.fsf_-_@fess.ebiederm.org>
	 <AANLkTilVHF0dITpB3yJYaCnGPonhdl7NWnb-P12RAFTs@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:46906 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051Ab0FTLdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 07:33:55 -0400
In-Reply-To: <AANLkTilVHF0dITpB3yJYaCnGPonhdl7NWnb-P12RAFTs@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-06-20 at 12:52 +0200, Kay Sievers wrote:

> As mentioned earlier, It's pretty fragile to change things in this
> area, and I prefer the broken network driver-core interactions to be
> fixed instead - even when they are more complicated.

Can you _please_ offer a proper way to fix it then?

johannes

