From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 8/8 V2] MX27ADS: Add CS89x0 support
Date: Wed, 29 Apr 2009 09:15:12 +0200
Message-ID: <20090429071512.GJ3696@pengutronix.de>
References: <1240963177-23941-1-git-send-email-vbarinov@embeddedalley.com> <1240963405-24007-1-git-send-email-vbarinov@embeddedalley.com> <20090428.231946.27173581.davem@davemloft.net> <49F7FBC8.7090705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Vladimir Barinov <vova.barinov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44238 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbZD2HPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 03:15:15 -0400
Content-Disposition: inline
In-Reply-To: <49F7FBC8.7090705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2009 at 11:03:36AM +0400, Vladimir Barinov wrote:
> Hello David,
>
> David Miller wrote:
>> From: Vladimir Barinov <vova.barinov@gmail.com>
>> Date: Wed, 29 Apr 2009 04:03:25 +0400
>>
>>   
>>> Add CS89x0 net chip support for MX27ADS board
>>>
>>> Signed-off-by: Vladimir Barinov <vbarinov@embeddedalley.com>
>>>     
>>
>> So what's the story with the apparent 7 patches that preceed this
>> one and this one seems to depend upon?
>>
>> Context, please :)
>>
>>   
> The patchset description is:
>
> The following patch series makes transition to setup all pins at once in
> platfrom code. Also it adds NAND, I2C, Framebuffer, SDHC, EXPIO(CPLD),
> CS89x0 devices support for MX27ADS board.

The important information is that PATCH8/8 does not depend on the
previous seven patches and can be applied independently.

You shouldn't have added it to this series but sent an extra patch to
David.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
