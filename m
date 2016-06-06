From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/9] net: dsa: Provide unique DSA slave MII bus names
Date: Mon, 06 Jun 2016 09:36:13 -0400
Message-ID: <87oa7ejv76.fsf@ketchup.mtl.sfl>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com> <1464998733-10405-6-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:60410 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbcFFNgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 09:36:16 -0400
In-Reply-To: <1464998733-10405-6-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> In case we have multiples trees and switches with the same index, we
> need to add another discriminating id: the switch tree.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
