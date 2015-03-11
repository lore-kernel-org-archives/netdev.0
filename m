From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 3/3] net: dsa: mv88e6171: Add EEE support to the mv88e6172
Date: Tue, 10 Mar 2015 19:09:31 -0700
Message-ID: <54FFA3DB.10709@roeck-us.net>
References: <1426025160-13992-1-git-send-email-andrew@lunn.ch> <1426025160-13992-4-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:35551 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbbCKCJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 22:09:34 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YVW5V-001tvE-H4
	for netdev@vger.kernel.org; Wed, 11 Mar 2015 02:09:33 +0000
In-Reply-To: <1426025160-13992-4-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2015 03:05 PM, Andrew Lunn wrote:
> The mv88e6172 has support for EEE. Check for the product ID and call
> the common code if applicable.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Guenter Roeck <linux@roeck-us.net>
