From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd)
Date: Mon, 13 Oct 2008 16:35:08 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810131633370.3843@wrl-59.cs.helsinki.fi>
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
 <Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
 <48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com> <alpine.LFD.2.00.0810052008131.3398@apollo>
 <48ed0b51.0913c00a.7715.4aa7@mx.google.com> <alpine.LFD.2.00.0810082154420.3237@apollo>
 <48f2c9d7.0603c00a.1df2.ffff9357@mx.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1769013299-1223904908=:3843"
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47687 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762166AbYJMNfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 09:35:10 -0400
In-Reply-To: <48f2c9d7.0603c00a.1df2.ffff9357@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1769013299-1223904908=:3843
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 13 Oct 2008, Dâniel Fraga wrote:

> On Wed, 8 Oct 2008 21:56:00 +0200 (CEST)
> Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> > Will do. Sorry was distracted. Steven Rostedt posted a patch to stop
> > the tracer really from the kernel, I need to verify that it works on
> > .27. Will do tomorrow when my brain is more awake than now.
> 
> 	Hi Thomas, did you have time to verify that patch? If so, I'd
> like to test it. Thanks.

http://marc.info/?t=122365716200001&r=1&w=2

...might turn out related. It has somewhat similar problem though 
different syscall. Not enough info on what kernel version etc. 
there though.


-- 
 i.
---696208474-1769013299-1223904908=:3843--
