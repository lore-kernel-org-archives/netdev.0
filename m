From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usbnet: update addr_assign_type if appropriate
Date: Fri, 30 Aug 2013 14:41:18 -0400 (EDT)
Message-ID: <20130830.144118.1671225313340653567.davem@davemloft.net>
References: <1377171946-19133-1-git-send-email-bjorn@mork.no>
	<87d2ovxcrx.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, oneukum@suse.de
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756702Ab3H3SlU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:41:20 -0400
In-Reply-To: <87d2ovxcrx.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Fri, 30 Aug 2013 20:18:58 +0200

> Bj=F8rn Mork <bjorn@mork.no> writes:
>=20
>> This module generates a common default address on init,
>> using eth_random_addr. Set addr_assign_type to let
>> userspace know the address is random unless it was
>> overridden by the minidriver.
>>
>> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
>=20
> David,
>=20
> I see that this patch is marked "Changes Requested" in patchworks:
> http://patchwork.ozlabs.org/patch/269030/
>=20
> But I haven't seen any request for changes, only Olivers ack. And tha=
t's
> all patchworks has recorded as well. Did I miss something?

Your v2 of this series is all marked as Under Review.

You have to understand, wrt. your initial submission, when someone
asks for changes in one of the patches in a series I mark the whole
series as changes requested.

This gives a second level of reminder that when one patch needs changes
I expect the entire series to be resubmitted.
