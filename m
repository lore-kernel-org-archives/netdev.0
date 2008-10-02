From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd)
Date: Fri, 3 Oct 2008 00:19:08 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
 <48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
 <alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
 <48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
 <alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
 <48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
 <alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
 <48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
 <alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
 <Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
 <48e5364d.0603c00a.6e25.fffff993@mx.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1085479966-1222981784=:22964"
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34177 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754289AbYJBVTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 17:19:33 -0400
In-Reply-To: <48e5364d.0603c00a.6e25.fffff993@mx.google.com>
Content-ID: <Pine.LNX.4.64.0810030013590.22964@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1085479966-1222981784=:22964
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810030013591.22964@wrl-59.cs.helsinki.fi>

On Thu, 2 Oct 2008, Dâniel Fraga wrote:

> On Thu, 2 Oct 2008 23:31:28 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > Ah, I was kind of thinking that you were doing something net related 
> > using some raw socket thing (such as traceroute) when you earlier 
> > mentioned sudo (iirc, we never really discussed what you usually do with 
> > it when you see the stall).
> 
> 	I read nntp groups everyday and I use leafnode. The stall on my
> desktop happens when I run fetchnews (which must be run as user "news"
> so I have to use sudo). Usually the stall on my desktop happens when
> I'm using fetchnews or some other command run by sudo.

Yes yes, I'd be specificly interested to have some rough idea what that
"some other command" includes, especially as some seem to be non-net 
related since you mentioned e.g., that /dev/log thing?


-- 
 i.
---696208474-1085479966-1222981784=:22964--
