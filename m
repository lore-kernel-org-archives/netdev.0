From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 01/12] net: dsa: mv88e6131: Use common initialization
 functions
Date: Wed, 01 Apr 2015 18:39:35 -0700
Message-ID: <551C9DD7.7040505@roeck-us.net>
References: <1427937719-11630-1-git-send-email-andrew@lunn.ch> <1427937719-11630-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:36083 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbbDBBjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 21:39:37 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YdU6a-000k3I-MN
	for netdev@vger.kernel.org; Thu, 02 Apr 2015 01:39:36 +0000
In-Reply-To: <1427937719-11630-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/2015 06:21 PM, Andrew Lunn wrote:
> From: Guenter Roeck <linux@roeck-us.net>
>
> Common initialization functions will be needed to enable
> HW bridging support.
>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Hi Andrew,

No idea how David handles this, but I would have expected to see your
Signed-off-by: here to reflect the submit path.

Thanks,
Guenter
