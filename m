From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 10/17] net: dsa: mv88e6xxx: Only support EDSA tagging
Date: Fri, 03 Jun 2016 14:51:35 -0400
Message-ID: <878tymnm14.fsf@ketchup.mtl.sfl>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch> <1464972256-10408-11-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50757 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296AbcFCSvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 14:51:39 -0400
In-Reply-To: <1464972256-10408-11-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> The merged driver no longer offers the option to use DSA tagging. So
> remove the code to setup the switch to do DSA tagging and hard code
> the use of EDSA.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
