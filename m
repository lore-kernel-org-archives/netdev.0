From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: init maximum receive buffer size for ring1 and
 ring2
Date: Tue, 25 Nov 2014 01:27:17 +0000
Message-ID: <BLUPR03MB37317746454BEF4E500B1D8F5730@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1416734586-26634-1-git-send-email-b38611@freescale.com>
 <20141124.152250.380142287256307570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"festevam@gmail.com" <festevam@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0147.outbound.protection.outlook.com ([207.46.100.147]:44864
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750784AbaKYBnL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 20:43:11 -0500
In-Reply-To: <20141124.152250.380142287256307570.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net> Sent: Tuesday, November 25, 2014 4:23 AM
>To: Duan Fugang-B38611
>Cc: netdev@vger.kernel.org; bhutchings@solarflare.com;
>stephen@networkplumber.org; festevam@gmail.com
>Subject: Re: [PATCH] net: fec: init maximum receive buffer size for ring1
>and ring2
>
>From: Fugang Duan <b38611@freescale.com>
>Date: Sun, 23 Nov 2014 17:23:06 +0800
>
>> i.MX6SX fec support three rx ring1, the current driver lost to init
>> ring1 and ring2 maximum receive buffer size, that cause receving frame
>> date length error. The driver reports "rcv is not +last" error log in
>> user case.
>>
>> Signed-off-by: Fugang Duan <B38611@freescale.com>
>
>This patch does not apply to the 'net' tree, although it does apply
>cleanly to the net-next tree.
>
>Determining which tree a patch is for is not my job, it is your's.
>
>Therefore you must always explicitly state what tree your patch is
>intended to be added to, by starting your Subject line with "[PATCH net] "
>or "[PATCH net-next] ".
>
>I've applied this, but next time I will just ask you to properly submit
>the patch instead.

David, thanks. I note this the next time.

Regards,
Andy
