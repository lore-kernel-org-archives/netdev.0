From: Patrick McHardy <kaber@trash.net>
Subject: Re: [2.6 patch] make nf_ct_ipv6_skip_exthdr() static
Date: Mon, 30 Jul 2007 14:30:29 +0200
Message-ID: <46ADD9E5.3050104@trash.net>
References: <20070729145846.GZ16817@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>,
	netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36244 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbXG3Mar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 08:30:47 -0400
In-Reply-To: <20070729145846.GZ16817@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> nf_ct_ipv6_skip_exthdr() can now become static.


Applied, thanks.
