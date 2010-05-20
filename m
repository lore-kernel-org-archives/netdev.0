From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: bnx2x + SFP+ DA/2.6.33.3: Got bad status 0x0 when reading from
 SFP+ EEPROM -> SFP+ module is not initialized
Date: Thu, 20 May 2010 22:54:54 +0200
Message-ID: <4BF5A19E.5010003@ans.pl>
References: <4BF56CA6.8080306@ans.pl>	<1274377770.28702.4.camel@lb-tlvb-eilong.il.broadcom.com>	<4BF57ADF.1060203@ans.pl>	<1274381113.28702.6.camel@lb-tlvb-eilong.il.broadcom.com> <4BF59058.6050205@ans.pl> <4BF59ABB.9070600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eilong@broadcom.com, Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:51246 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757089Ab0ETUzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 16:55:04 -0400
In-Reply-To: <4BF59ABB.9070600@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-05-20 22:25, Rick Jones wrote:
> Some simple/simplistic thoughts/questions...
>
> Has the DAC been used successfully prior to this?

Yes. It was successfully used to connect two HP switches, before I=20
received SFP+ SR modules, that allowed me to put the switches into=20
distanced rooms.

> Do you have another HP ProCurve 10-GbE SFP+ 7m Direct Attach Cable (J=
9285B) to try?

Yes. The same situation.

> There's a transceiver and presumably an EEPROM at both ends of a DAC =
right?

Yes, I think there should be one. ;)

> If
> the EEPROM at one end were "bad" might the 57711 be happier with the =
other end
> of the DAC?

Tested both ends. The same situation. :|

> Getting some sort of error message at the switch side, which may
> (or may not) have more detailed diagnostics might help.

There is no error message at the switch side. The switch shows that=20
everything is correct.

Best regards,

				Krzysztof Ol=C4=99dzki
