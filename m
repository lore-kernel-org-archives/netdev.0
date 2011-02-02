From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bna: use device model DMA API
Date: Wed, 02 Feb 2011 15:41:41 -0800 (PST)
Message-ID: <20110202.154141.245418837.davem@davemloft.net>
References: <1296657422-13537-1-git-send-email-ivecera@redhat.com>
	<20110202.150308.246520172.davem@davemloft.net>
	<AANLkTinG_DcSPc7ReyxXE6T5fhoQkKmmtMLv4j9BAxMx@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ivecera@redhat.com, netdev@vger.kernel.org, rmody@brocade.com,
	ddutt@brocade.com
To: debdut@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45103
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751278Ab1BBXlF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 18:41:05 -0500
In-Reply-To: <AANLkTinG_DcSPc7ReyxXE6T5fhoQkKmmtMLv4j9BAxMx@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Debashis Dutt <debdut@gmail.com>
Date: Wed, 2 Feb 2011 15:12:00 -0800

> On Wed, Feb 2, 2011 at 3:03 PM, David Miller <davem@davemloft.net> wr=
ote:
>>
>> From: Ivan Vecera <ivecera@redhat.com>
>> Date: Wed, =A02 Feb 2011 15:37:02 +0100
>>
>> > Use DMA API as PCI equivalents will be deprecated.
>> >
>> > Signed-off-by: Ivan Vecera <ivecera@redhat.com>
>>
>> Looks good to me, can we get some review from the BNA maintainers
>> please?
>> --
>=20
> For some reason, ACK from my Brocade mail Id does not show up in the
> netdev mailing list.
>=20
> The patch looks good to me too.

Thanks for reviewing, applied.
