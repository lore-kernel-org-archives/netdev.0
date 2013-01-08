From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] net: fec: Place 'inline' in the beginning of
 declaration
Date: Mon, 07 Jan 2013 19:35:44 -0800
Message-ID: <1357616144.12749.43.camel@joe-AO722>
References: <1357615751-11659-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shawn.guo@linaro.org, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54435 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751316Ab3AHDfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 22:35:44 -0500
In-Reply-To: <1357615751-11659-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-08 at 01:29 -0200, Fabio Estevam wrote:
> The inline declaration is pointless in this function, so just remove it.

Perhaps remove all 3 inlines from the file at the same time.
