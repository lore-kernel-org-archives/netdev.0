From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCHv2 net-2.6 0/4 (was 0/3)]: TCP fixes
Date: Tue, 8 Apr 2008 00:59:45 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804080050060.20948@wrl-59.cs.helsinki.fi>
References: <1207569344-19687-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-335314727-1207605585=:20948"
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Robin H. Johnson" <robbat2@gentoo.org>,
	Georgi Chorbadzhiyski <gf@unixsol.org>,
	Soeren Sonnenburg <kernel@nn7.de>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	Alessandro Suardi <alessandro.suardi@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49580 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757361AbYDGV7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 17:59:47 -0400
In-Reply-To: <1207569344-19687-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-335314727-1207605585=:20948
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 7 Apr 2008, Ilpo Järvinen wrote:

> Ok, here's the v2 series 

[...snip...]

> ...So far, they're just compile tested. I'll see if I find some time
> to boot them on the evening.

$ uptime
 00:53:23 up  1:20,  6 users,  load average: 0.54, 0.22, 0.13

...some torrent & browsing, mainly with tso & tcp_sack = 0. Didn't hit 
any problems with it (I had my debug patch in as well).


-- 
 i.
---696208474-335314727-1207605585=:20948--
