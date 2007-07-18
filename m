From: Patrick McHardy <kaber@trash.net>
Subject: Re: pmtu discovery on SA
Date: Wed, 18 Jul 2007 20:27:44 +0200
Message-ID: <469E5BA0.6030200@trash.net>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local> <469B878C.1020204@trash.net> <469B8C47.3030306@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local> <469BB50C.10203@trash.net> <469CE9E5.7040003@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323024F@exch.facton.local> <469D3885.7070208@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230254@exch.facton.local> <469E1242.3050105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230257@exch.facton.local> <469E3F6F.6040004@trash.net> <469E465A.9000902@kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Beschorner Daniel <Daniel.Beschorner@facton.com>,
	netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44928 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014AbXGRS2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 14:28:18 -0400
In-Reply-To: <469E465A.9000902@kolumbus.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mika Penttil=E4 wrote:
> Patrick McHardy wrote:
>=20
>> Its a debugging message nowadays (NETDEBUG). I was mostly interested
>> in this since I changed the IPsec MTU calculation in 2.6.22 and it
>> might have been a bug.
>>
>>  =20
>=20
> And we don't have pmtu discovery for esp yet, right?


We do. The best I have seen to date in any IPsec implementation :)
