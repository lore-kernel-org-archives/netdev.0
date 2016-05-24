From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net 1/3] Documentation: networking: dsa: Remove poll_link description
Date: Tue, 24 May 2016 10:16:48 -0400
Message-ID: <877fejsfqn.fsf@ketchup.mtl.sfl>
References: <1464064337-8743-1-git-send-email-f.fainelli@gmail.com> <1464064337-8743-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49724 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932278AbcEXOQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 10:16:57 -0400
In-Reply-To: <1464064337-8743-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> This function has been removed in 4baee937b8d5 ("net: dsa: remove DSA
> link polling") in favor of using the PHYLIB polling mechanism.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
