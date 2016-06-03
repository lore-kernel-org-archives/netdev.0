From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 15/17] net: dsa: Add new binding implementation
Date: Fri, 03 Jun 2016 16:06:05 -0400
Message-ID: <87wpm6m40i.fsf@ketchup.mtl.sfl>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch> <1464972256-10408-16-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:53830 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932741AbcFCUGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 16:06:09 -0400
In-Reply-To: <1464972256-10408-16-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> The existing DSA binding has a number of limitations and problems. The
> main problem is that it cannot represent a switch as a linux device,
> hanging off some bus. It is limited to one CPU port. The DSA platform
> device is artificial, and does not really represent hardware.
>
> Implement a new binding which can be embedded into any type of node on
> a bus to represent one switch device, and its links to other switches.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
