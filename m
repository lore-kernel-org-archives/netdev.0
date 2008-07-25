From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.25: WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0xdd7/0x22f0()
Date: Fri, 25 Jul 2008 15:56:07 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807251553180.11302@wrl-59.cs.helsinki.fi>
References: <ecb4efd10806231553w8758655xcf861e5e191809ec@mail.gmail.com>
 <Pine.LNX.4.64.0807251550490.11302@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-695446208-1216990567=:11302"
Cc: Netdev <netdev@vger.kernel.org>
To: Clem Taylor <clem.taylor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40897 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbYGYM4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 08:56:09 -0400
In-Reply-To: <Pine.LNX.4.64.0807251550490.11302@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-695446208-1216990567=:11302
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 25 Jul 2008, Ilpo Järvinen wrote:

> On Mon, 23 Jun 2008, Clem Taylor wrote:
> 
> > My kernel is tainted with both the vmware and nvidia drivers, but I
> > thought someone might still care about this.
> >
> > The system is 2.6.25 x86_64 SMP (with preeempt and tickless).
> >
> > [841839.294985] ------------[ cut here ]------------
> > [841839.294985] WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0xdd7/0x22f0()
> 
> Please upgrade to at least 2.6.25.7 or 2.6.26, if this still shows up with 
> it, then rereport (ccing me of course :-)).

...And, it's not deadly condition but any means anyway, but I'm trying to 
root all these minor miscounts out too, but due to rarity of the remaining 
bugs, it's getting harder and harder.

-- 
 i.
---696208474-695446208-1216990567=:11302--
