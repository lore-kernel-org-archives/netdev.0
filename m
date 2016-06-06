From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 5/9] net: dsa: Export suspend/resume functions
Date: Mon, 06 Jun 2016 09:40:26 -0400
Message-ID: <87lh2ijv05.fsf@ketchup.mtl.sfl>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com> <1464998733-10405-8-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:60680 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852AbcFFNka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 09:40:30 -0400
In-Reply-To: <1464998733-10405-8-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> In preparation for allowing switch drivers to implement system-wide
> suspend/resume functions, export dsa_switch_suspend and
> dsa_switch_resume() such that these are callable from the appropriate
> driver specific suspend/resume functions.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
