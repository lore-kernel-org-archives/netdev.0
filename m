From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Netperf TCP_RR(loopback) 10% regression in 2.6.24-rc6,	comparing
 with 2.6.22
Date: Mon, 14 Jan 2008 11:21:17 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801141118450.31652@kivilampi-30.cs.helsinki.fi>
References: <1199871330.3298.132.camel@ymzhang> <1200043854.3265.24.camel@ymzhang>
 <Pine.LNX.4.64.0801141036400.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-940495112-1200302477=:31652"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33314 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbYANJVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 04:21:19 -0500
In-Reply-To: <Pine.LNX.4.64.0801141036400.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-940495112-1200302477=:31652
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 14 Jan 2008, Ilpo Järvinen wrote:

> On Fri, 11 Jan 2008, Zhang, Yanmin wrote:
> 
> > On Wed, 2008-01-09 at 17:35 +0800, Zhang, Yanmin wrote: 
> > > 
> > > As a matter of fact, 2.6.23 has about 6% regression and 2.6.24-rc's
> > > regression is between 16%~11%.
> > > 
> > > I tried to use bisect to locate the bad patch between 2.6.22 and 2.6.23-rc1,
> > > but the bisected kernel wasn't stable and went crazy.
> 
> TCP work between that is very much non-existing.

I _really_ meant 2.6.22 - 2.6.23-rc1, not 2.6.24-rc1 in case you had a 
typo there which is not that uncommon while typing kernel versions... :-)

-- 
 i.
---696243703-940495112-1200302477=:31652--
