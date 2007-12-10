From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.24-rc4-mm1
Date: Mon, 10 Dec 2007 22:05:24 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712102203010.11235@kivilampi-30.cs.helsinki.fi>
References: <20071204211701.994dfce6.akpm@linux-foundation.org>
 <47579DD9.9030909@reub.net> <20071205233504.67366c5b.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0712101136190.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-910908797-1197317124=:11235"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Reuben Farrelly <reuben-linuxkernel@reub.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Auke Kok <auke-jan.h.kok@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60656 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754382AbXLJUF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 15:05:26 -0500
In-Reply-To: <Pine.LNX.4.64.0712101136190.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-910908797-1197317124=:11235
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 10 Dec 2007, Ilpo Järvinen wrote:

> Dave, please include this one to net-2.6.25.

...

> --
> [PATCH] [TCP]: Fix fack_count miscountings (multiple places)

I've better version of this coming up, so Dave please don't put this one 
into net-2.6.25 (noticed that both the original and the after patch code 
can get to an infinite loop and the new code is flawed in some rare cases 
still as well). I'll submit a better version soon.

-- 
 i.
---696243703-910908797-1197317124=:11235--
