From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP]: Make invariant check complain about invalid
 sacked_out
Date: Wed, 5 Dec 2007 21:36:37 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712052135530.9572@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712052133490.9572@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696243703-1284969860-1196883329=:9572"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38291 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbXLETgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 14:36:39 -0500
In-Reply-To: <Pine.LNX.4.64.0712052133490.9572@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0712052135531.9572@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1284969860-1196883329=:9572
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712052135532.9572@kivilampi-30.cs.helsinki.fi>

On Wed, 5 Dec 2007, Ilpo Järvinen wrote:

> 
> Earlier resolution for NewReno's sacked_out should now keep
> it small enough for this to become invariant-like check.
> 
> Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

Forgot to modify it to the subject, this one to net-2.6.25 please.

-- 
 i.
---696243703-1284969860-1196883329=:9572--
