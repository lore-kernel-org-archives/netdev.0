From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Mon, 12 May 2008 21:23:18 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805122120540.14152@wrl-59.cs.helsinki.fi>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi>
 <4821C37A.7040306@damtek.com> <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
 <4823437D.20005@damtek.com> <Pine.LNX.4.64.0805082336440.31776@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0805120859470.1041@wrl-59.cs.helsinki.fi> <4828279C.3010102@damtek.com>
 <Pine.LNX.4.64.0805121419330.1888@wrl-59.cs.helsinki.fi> <4828304F.4040908@damtek.com>
 <Pine.LNX.4.64.0805121503280.1888@wrl-59.cs.helsinki.fi> <482849C9.30905@damtek.com>
 <Pine.LNX.4.64.0805121656440.1888@wrl-59.cs.helsinki.fi> <48287817.5030309@damtek.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary=------------030405060003060204050804
Cc: Netdev <netdev@vger.kernel.org>
To: "Damon L. Chesser" <damon@damtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57963 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753720AbYELSXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 14:23:20 -0400
In-Reply-To: <48287817.5030309@damtek.com>
Content-ID: <Pine.LNX.4.64.0805122121390.14152@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--------------030405060003060204050804
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0805122120542.14152@wrl-59.cs.helsinki.fi>

On Mon, 12 May 2008, Damon L. Chesser wrote:

> Ilpo Järvinen wrote:
> >
> > ...Can you please send a dump about working case too, this seems rather
> > nasty device to work with (tcp_frto = 0 is enough to attain it, no need to
> > have another kernel booted for that) and I'm interested to see what are the
> > loss rates without FRTO...
> >
> >
> Attached is the compressed "good" test with tcp_frto = 0.  Sorry about the
> size, I did not think to compress the earlier ones.  Five test pages printed,
> no errors.  I will get a new kernel compiled shortly, and tested as you
> requested.

...Thanks, I'll have a look.

There was no need to compress the earlier ones as they were not that 
large, but I realized after asking that one might hit netdev size cutter 
without compression when things worked, thus compression :-).

-- 
 i.
--------------030405060003060204050804--
