From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Wed, 4 Jun 2008 18:09:22 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806041802360.2580@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu> <1211966834.12349.62.camel@twins>
  <a01a16b50805310725x4f1c375ep2d091bb044ac0787@mail.gmail.com>
 <Pine.LNX.4.64.0805311839540.2657@wrl-59.cs.helsinki.fi>  <484191BD.8000904@gmail.com>
  <Pine.LNX.4.64.0805312119270.2672@wrl-59.cs.helsinki.fi>
 <a01a16b50805311325w7f58ca69h93d02af9bc28d2ea@mail.gmail.com>
 <Pine.LNX.4.64.0805312332270.2760@wrl-59.cs.helsinki.fi>
 <a01a16b50806031710u54b9297bkf1fad9c4f8fd581f@mail.gmail.com>
 <Pine.LNX.4.64.0806041402211.16829@wrl-59.cs.helsinki.fi>
 <a01a16b50806040700h1efce63cq2a27b087df0d25be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1745598132-1212592162=:2580"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: "=?UTF-8?Q?H=C3=A5kon_L=C3=B8vdal?=" <hlovdal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36494 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbYFDPJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 11:09:24 -0400
In-Reply-To: <a01a16b50806040700h1efce63cq2a27b087df0d25be@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1745598132-1212592162=:2580
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 4 Jun 2008, Håkon Løvdal wrote:

> 2008/6/4 Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>:
>
> > Usually such logs compress quite well. A best thing might be to put
> > somewhere (if possible) and http:// reference them.

> The largest file was a strace log of 1.5GB uncompressed. I will try to
> sort out something.

I guess not all of the strace will be necessary anyway. You could first 
leave that out completely and concentrate on the other logs first.

-- 
 i.
---696208474-1745598132-1212592162=:2580--
