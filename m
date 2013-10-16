From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net v2] be2net: Warn users of possible broken functionality
 on BE2 cards with very old FW versions with latest driver
Date: Wed, 16 Oct 2013 16:59:51 +0200
Message-ID: <525EA9E7.409@redhat.com>
References: <cca19523-3f51-4f87-b0e1-2ecec6ba37d4@CMEXHTCAS1.ad.emulex.com> <20131007.123116.1462434377931881914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34451 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752630Ab3JPO7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 10:59:55 -0400
In-Reply-To: <20131007.123116.1462434377931881914.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2013 06:31 PM, David Miller wrote:
> From: Somnath Kotur <somnath.kotur@emulex.com>
> Date: Thu, 3 Oct 2013 15:34:29 +0530
>
>> +	if (BE2_chip(adapter) && memcmp(adapter->fw_ver, "4.", 2) < 0) {
>> +		dev_err(dev, "Firmware version is too old.IRQs may not work\n");
>
> So many grammatical mistakes in one line.
>
> First sentence got a period, second one did not.
>
> Missing space between period and second sentence.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
Som, any plan to send v3?

Ivan
