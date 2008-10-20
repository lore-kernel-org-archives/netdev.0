From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd)
Date: Tue, 21 Oct 2008 00:49:13 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810210048370.30254@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
 <48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
 <alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
 <48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
 <alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
 <48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
 <alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
 <Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
 <48e5364d.0603c00a.6e25.fffff993@mx.google.com>
 <Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
 <48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com> <alpine.LFD.2.00.0810052008131.3398@apollo>
 <48ed0b51.0913c00a.7715.4aa7@mx.google.com> <alpine.LFD.2.00.0810082154420.3237@apollo>
 <48f2c9d7.0603c00a.1df2.ffff9357@mx.google.com>
 <Pine.LNX.4.64.0810131633370.3843@wrl-59.cs.helsinki.fi>
 <48f9251b.1626360a.6574.61ec@mx.google.com> <Pine.LNX.4.64.0810210028550.30254@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696208474-1848296723-1224538511=:30254"
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?D=E2niel_Fraga?=" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59181 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbYJTVtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 17:49:14 -0400
In-Reply-To: <Pine.LNX.4.64.0810210028550.30254@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0810210048371.30254@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1848296723-1224538511=:30254
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810210045181.30254@wrl-59.cs.helsinki.fi>

On Tue, 21 Oct 2008, Ilpo Järvinen wrote:

> Trying something a bit more generic:
> 
> Try running vmstat 1 > somelog.file to see if there's something 
> particularly interesting behavior during the stall.

Won't hurt doing this on both the server and the client... :-)

-- 
 i.
---696208474-1848296723-1224538511=:30254--
