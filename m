From: Nishanth Menon <nm@ti.com>
Subject: Re: [PATCH] phy: add support for a reset-gpio specification
Date: Thu, 12 May 2016 09:05:15 -0500
Message-ID: <57348D9B.2080200@ti.com>
References: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <57348A2A.8070806@ti.com> <57348D05.905@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <kernel@pengutronix.de>, "Andrew F . Davis" <afd@ti.com>,
	Sekhar Nori <nsekhar@ti.com>, Suman Anna <s-anna@ti.com>
To: Roger Quadros <rogerq@ti.com>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	<netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([198.47.19.12]:39101 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751901AbcELOPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2016 10:15:38 -0400
In-Reply-To: <57348D05.905@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/12/2016 09:02 AM, Roger Quadros wrote:
[...]
>> This looks like the right approach to me at least: I see that TI EVMs
>> will also benefit with this approach.
>>
> 
> Agreed. Although on some of our boards we actually need a RESET pulse
> to get the PHY in a sane state. I can send a patch on top for that.
> 
> Reviewed-by: Roger Quadros <rogerq@ti.com>

There is an interesting thread starting up on Linux-arm[1] as well - I
guess Uwe can comment on direction.

[1] http://marc.info/?t=146303744800003&r=1&w=2


-- 
Regards,
Nishanth Menon
