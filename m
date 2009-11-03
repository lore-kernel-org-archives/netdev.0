From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy on 10GbE
Date: Tue, 3 Nov 2009 10:54:13 +0000
Message-ID: <20091103105413.GD6718@ff.dom.local>
References: <4AF0023C.5010404@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:63479 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbZKCKyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 05:54:13 -0500
Received: by bwz27 with SMTP id 27so7422626bwz.21
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2009 02:54:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4AF0023C.5010404@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03-11-2009 11:13, Badalian Vyacheslav wrote:
>> Really?! As a matter of fact there isn't fully used the last change,
>> especially this part:
>>
>> http://marc.info/?l=3Dlinux-netdev&m=3D124453482324409&w=3D2
>>
>> And nobody even noticed it for quite a long time. I'm not even sure
>> Ryousei needs this now for anything but comparing with some better
>> tool...
>=20
> These changes have not been tested and applied to kernel?
>=20
> As I now remember, I promised to test this patch and judging by=20
> correspondence so it and have not made. My error - I am ready to
> correct it. Probably there were difficulties, and is then banal=20
> has forgotten.
> It is possible to receive once again full ???=B0N~?N~?N~???N~? for th=
e test?

There were a few iproute changes, tested enough I guess. Alas, I
didn't keep them (they could be found around with link above).

But it's not about your testing. I meant: since nobody noticed
something was (still) wrong with 1G scheduling, why bother with 10G?

Best regards,
Jarek P.

PS: ...and don't remove me from CC, please ;-)
