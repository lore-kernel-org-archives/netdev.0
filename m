From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH 2/6] net: dsa: allow switch drivers to cleanup their
 resources
Date: Wed, 28 Oct 2015 14:56:18 +0100
Message-ID: <5630D402.8010006@baylibre.com>
References: <562F8ED7.2000804@baylibre.com> <562F9AAB.8090202@gmail.com>
 <562F9BB1.8090700@baylibre.com> <20151027165932.GA21799@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:34879 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965631AbbJ1N4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 09:56:24 -0400
Received: by wmll128 with SMTP id l128so7820992wml.0
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 06:56:23 -0700 (PDT)
In-Reply-To: <20151027165932.GA21799@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2015 05:59 PM, Vivien Didelot wrote:
> On Oct. Tuesday 27 (44) 04:43 PM, Neil Armstrong wrote:
>>
>> Yes, I didn't know how to handle this since it was part of a larger patch.
>>
>> I forgot to add this into the cover-letter but I wanted to send an RFC serie with
>> your bcm remove patch and a mv88e6xxx remove experimental code.
>>
>> Yet, the mv88e6060 does not make usage of this.
> 
> So this patch must be part of your RFC for module removal instead of
> this patchset.
> 
> Thanks,
> -v
> 

Vivien, Florian,

Thanks for the review, I will integrate it in the other RFC patchset with the correct Signed-off-by tag.

Neil
