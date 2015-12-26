From: Mason <slash.tmp@free.fr>
Subject: Re: Small improvements for the at803x PHY driver
Date: Sat, 26 Dec 2015 12:57:17 +0100
Message-ID: <567E809D.3000902@free.fr>
References: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Daniel Mack <daniel@zonque.org>,
	Fabio Estevam <festevam@gmail.com>,
	Mans Rullgard <mans@mansr.com>
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:33883 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253AbbLZL5c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Dec 2015 06:57:32 -0500
In-Reply-To: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ CCing people who might be interested in this patch series ]

On 26/12/2015 01:26, Martin Blumenstingl wrote:

> while trying to debug a problem on a board with an AR8030 PHY (which turned
> out to be an incorrectly configured MDC clock) I made a few changes to the
> at803x driver.
> Due to lack of other hardware I could only test these changes with an
> AR8030 chip.
