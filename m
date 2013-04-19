From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 05/15] igb: Support to read and export
 SFF-8472/8079 data
Date: Fri, 19 Apr 2013 14:20:00 -0400 (EDT)
Message-ID: <20130419.142000.553422110375189224.davem@davemloft.net>
References: <1366327822-10741-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<1366328268.2248.60.camel@jtkirshe-mobl>
	<1366328515.2248.61.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, akeem.g.abodunrin@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	footplus@gmail.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45137 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972Ab3DSSUE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 14:20:04 -0400
In-Reply-To: <1366328515.2248.61.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 18 Apr 2013 16:41:55 -0700

> On Thu, 2013-04-18 at 16:37 -0700, Jeff Kirsher wrote:
>> On Thu, 2013-04-18 at 16:30 -0700, Jeff Kirsher wrote:
>> > From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>
>> >=20
>> > This patch adds support to read and export SFF-8472/8079 (SFP data=
)
>> > over i2c, through Ethtool.
>> >=20
>> > v2: Changed implementation to accommodate any offset within SFF
>> module
>> >     length boundary.
>> >=20
>> > Reported-by: Aur=E9lien Guillaume <footplus@gmail.com>
>> > CC: Aur=E9lien Guillaume <footplus@gmail.com>
>> > CC: Ben Hutchings <bhuntchings@solarflare.com>
>>=20
>> Looks like Akeem made a typo in your email Ben.
>=20
> I have fixed up your email in the patch that resides in my net-next
> tree.

Thanks for fixing this up.
