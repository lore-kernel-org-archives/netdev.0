From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Mon, 24 Jan 2011 13:02:13 -0800 (PST)
Message-ID: <20110124.130213.193692922.davem@davemloft.net>
References: <1295697376-2984-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<AANLkTikmt1BsuLmw+6Lv_trPfRzHYdjWY-61DPv_3T7y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44595
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751384Ab1AXVBi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 16:01:38 -0500
In-Reply-To: <AANLkTikmt1BsuLmw+6Lv_trPfRzHYdjWY-61DPv_3T7y@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 24 Jan 2011 00:19:30 -0800

> On Sat, Jan 22, 2011 at 03:56, Jeff Kirsher <jeffrey.t.kirsher@intel.=
com> wrote:
>> The following series contains cleanups for e1000e and addition suppo=
rt
>> for the i340 adapter in igb.
>>
>> The following are changes since commit bb134d2298b49f50cf6d9388410fb=
a96272905dc:
>> =A0net: netif_setup_tc() is static
>>
>> and are available in the git repository at:
>> =A0master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6=
 master
>>
>> Bruce Allan (2):
>> =A0e1000e: reduce scope of some variables, remove unnecessary ones
>> =A0e1000e: Use kmemdup rather than duplicating its implementation
>>
>> Carolyn Wyborny (1):
>> =A0igb: Add support for i340 Quad Port Fiber Adapter
>>
>> Jeff Kirsher (1):
>> =A0e1000e: convert to stats64
>>
>=20
> I have updated my tree to include Flavio's Signed-off-by on the follo=
wing patch:
>=20
> e1000e: convert to stats64

Pulled, thanks a lot Jeff.
