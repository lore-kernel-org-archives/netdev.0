From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c
Date: Mon, 12 May 2008 13:50:33 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805121349400.1888@wrl-59.cs.helsinki.fi>
References: <4815BCDF.6070704@andyfurniss.entadsl.com>
 <Pine.LNX.4.64.0804281714090.1888@wrl-59.cs.helsinki.fi>
 <48162070.4030405@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804282210390.16635@wrl-59.cs.helsinki.fi>
 <481986FD.8070108@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805011216230.19286@wrl-59.cs.helsinki.fi>
 <48199342.9010406@andyfurniss.entadsl.com> <Pine.LNX.4.64.0805021342480.30402@wrl-59.cs.helsinki.fi>
 <481C54AF.1050109@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1790587430-1210589433=:1888"
Cc: Netdev <netdev@vger.kernel.org>
To: Andy Furniss <lists@andyfurniss.entadsl.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41292 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbYELKue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 06:50:34 -0400
In-Reply-To: <481C54AF.1050109@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1790587430-1210589433=:1888
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 3 May 2008, Andy Furniss wrote:

> Ilpo Järvinen wrote:
> 
> > Since I've not yet found any other path that could lead to it except the
> > yesterday's false-positive, getting the write queue state more accurately
> > captured by the debug patch on the very first occassion might help. Here's
> > less spammy version of the debug patch (I added one printout as well to get
> > more usefulness to transitional state reported).
> > 
> 
> OK, increased CONFIG_LOG_BUF_SHIFT from 14 to 18 and reversed old / applied
> new patch.

Any luck so far?

-- 
 i.
---696208474-1790587430-1210589433=:1888--
