From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH] ath: wil6210: Fix build error
Date: Mon, 22 Jul 2013 09:17:01 -0700
Message-ID: <20130722161554.GR17130@pogo>
References: <1374374808-12768-1-git-send-email-Larry.Finger@lwfinger.net>
 <1958736.oRuXAUfNGd@lx-vladimir>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Larry Finger <Larry.Finger@lwfinger.net>, <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<wil6210@qca.qualcomm.com>, Stable <stable@vger.kernel.org>,
	Thomas Fjellstrom <thomas@fjellstrom.ca>
To: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:31744 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932962Ab3GVQRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 12:17:04 -0400
Content-Disposition: inline
In-Reply-To: <1958736.oRuXAUfNGd@lx-vladimir>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 21, 2013 at 10:06:31AM +0300, Vladimir Kondratiev wrote:
> Hmm, I have no warning for this with neither 3.10 nor 3.11 kernel version; but
> patch is correct, and here is my
> Signed-off-by: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>

If you agree with a patch you don't say you Sign-off-by it as well,
you say Acked-by. The Signed-off-by tag has a very specific meaning
from development to a maintainer's hands, and its definition is on
the Developer Certificate or Origin.

So in this case Acked-by is better.

  Luis
