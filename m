From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 1/3] net: dsa: Centralise getting switch id
Date: Tue, 10 Mar 2015 19:08:43 -0700
Message-ID: <54FFA3AB.1080400@roeck-us.net>
References: <1426025160-13992-1-git-send-email-andrew@lunn.ch> <1426025160-13992-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:35492 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752366AbbCKCIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 22:08:47 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YVW4j-001tbc-Jw
	for netdev@vger.kernel.org; Wed, 11 Mar 2015 02:08:46 +0000
In-Reply-To: <1426025160-13992-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2015 03:05 PM, Andrew Lunn wrote:
> Get the switch id and save it away in the private mv88x6xxx structure
> in a centralised piece of code, rather than each driver doing it itself.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Guenter Roeck <linux@roeck-us.net>
