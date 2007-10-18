From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at virtual
 address 000000b0
Date: Thu, 18 Oct 2007 15:15:13 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0710181514390.12701@bizon.gios.gov.pl>
References: <Pine.LNX.4.64.0710170833071.21430@bizon.gios.gov.pl>
 <4715B26E.20302@cosmosbay.com> <Pine.LNX.4.64.0710171018470.21430@bizon.gios.gov.pl>
 <4715E60E.3020401@cosmosbay.com> <Pine.LNX.4.64.0710171250480.21430@bizon.gios.gov.pl>
 <47161415.1060808@cosmosbay.com> <Pine.LNX.4.64.0710181320170.12701@bizon.gios.gov.pl>
 <4717477E.8000003@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-551523666-1192713313=:12701"
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:47311 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186AbXJRNPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 09:15:47 -0400
In-Reply-To: <4717477E.8000003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-551523666-1192713313=:12701
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Thu, 18 Oct 2007, Patrick McHardy wrote:

> Krzysztof Oledzki wrote:
>>> Hum, you are using IPT_TPROXY thing, which is not in linux-2.6.22.9
>>=20
>> It is only compiled in, not used at the moment.
>
> But at least the previous version (before those patches posted a week
> ago) touches the routing code in exactly that function.

Right. Thank you.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-551523666-1192713313=:12701--
