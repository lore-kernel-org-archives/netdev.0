From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH 8/8] [PKTGEN]: uninline getCurUs
Date: Mon, 14 Jan 2008 09:43:08 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801140920580.31652@kivilampi-30.cs.helsinki.fi>
References: <12001308174189-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20080112121740.GA4555@gondor.apana.org.au>
 <Pine.LNX.4.64.0801121420220.19333@kivilampi-30.cs.helsinki.fi>
 <20080112.202414.192104180.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-658551954-1200296588=:31652"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41967 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbYANHnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 02:43:12 -0500
In-Reply-To: <20080112.202414.192104180.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-658551954-1200296588=:31652
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 12 Jan 2008, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Sat, 12 Jan 2008 14:59:50 +0200 (EET)
> 
> > ...Maybe I just fall-back to changing my last name, it's the only 
> > full-proof solution... ;-)
> 
> Don't do this!  Otherwise I won't have a frequent test case to make
> sure my patch applying scripts are working properly. :-))))

So which test case you prefer? :-) Is iso-8859-1 from+content ok? Or 
should I keep trying to live with mixed utf-8 which I didn't got even 
fully working last time because git-send-email is probably either too dumb 
or too intelligent (I'm not even sure which), but you were able correct it 
by your tools so the flawed signed-off never entered to the git logs as 
incorrectly formatted :-).

I'd prefer sending them as iso-8859-1 compliant (and I guess you are able 
to test your fix-to-utf-8 machinery with it as well :-)), as it would also 
make my mails compatible with other people's git apply tools you're not 
using (otherwise I'd probably forget to change it occassionally when 
interacting with others than you).


-- 
 i.
---696243703-658551954-1200296588=:31652--
