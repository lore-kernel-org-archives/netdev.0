From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Mon, 07 Mar 2016 09:48:06 +0100
Message-ID: <1457340486.2737.19.camel@tiscali.nl>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
	 <1456945629-1793533-2-git-send-email-arnd@arndb.de>
	 <56D7F62E.6050502@linux-pingi.de> <1659125.tHp8H942OG@wuerfel>
	 <1457108303.2651.112.camel@tiscali.nl> <56DADA57.9010200@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>,
	linux-arm-kernel@lists.infradead.org, isdn@linux-pingi.de,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devel@driverdev.osuosl.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Tilman Schmidt <tilman@imap.cc>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud3.xs4all.net ([194.109.24.26]:38338 "EHLO
	lb2-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752082AbcCGIsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 03:48:10 -0500
In-Reply-To: <56DADA57.9010200@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On za, 2016-03-05 at 14:08 +0100, Tilman Schmidt wrote:
> As a consequence, owners of HiSAX type adapters are in fact stuck with
> the old hisax driver if they want to continue using i4l userspace
> tools.

Do you know whether or not mISDN tools offer functionality comparable to
i4l tools?


Paul Bolle
