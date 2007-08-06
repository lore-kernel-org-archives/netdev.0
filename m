From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP's initial cwnd setting correct?...
Date: Mon, 6 Aug 2007 21:31:22 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708062129440.29123@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0708061508070.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1790435711-1186425082=:29123"
Cc: David Miller <davem@davemloft.net>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45373 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755169AbXHFSbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 14:31:24 -0400
In-Reply-To: <Pine.LNX.4.64.0708061508070.8788@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1790435711-1186425082=:29123
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 6 Aug 2007, Ilpo Järvinen wrote:

> ...Goto logic could be cleaner (somebody has any suggestion for better 
> way to structure it?)

...I could probably move the setting of snd_cwnd earlier to avoid 
this problem if this seems a valid fix at all.

-- 
 i.
---696243703-1790435711-1186425082=:29123--
