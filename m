From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 1/2] Issue NETDEV_CHANGE notification when bridge
 changes state
Date: Sat, 5 Mar 2011 22:43:03 -0800 (PST)
Message-ID: <1154832100.13939.1299393783798.JavaMail.root@tahiti.vyatta.com>
References: <20110306051833.GA3098@mira.lan.galacticasoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Adam Majer <adamm@zombino.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34773 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917Ab1CFGnF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Mar 2011 01:43:05 -0500
In-Reply-To: <20110306051833.GA3098@mira.lan.galacticasoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Why not set forwarding delay to zero? I don't think you are using STP?

P.s: removing linux-kernel mailing list, since there is no point
in copying the whole world on this thread.
