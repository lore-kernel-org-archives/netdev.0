From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH 8/8] [PKTGEN]: uninline getCurUs
Date: Sat, 12 Jan 2008 14:59:50 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801121420220.19333@kivilampi-30.cs.helsinki.fi>
References: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12001308173014-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1200130817664-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12001308171814-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1200130817405-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12001308172525-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1200130817467-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12001308174189-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20080112121740.GA4555@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-212337342-1200140478=:19333"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40098 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757591AbYALM7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 07:59:53 -0500
In-Reply-To: <20080112121740.GA4555@gondor.apana.org.au>
Content-ID: <Pine.LNX.4.64.0801121441240.19333@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-212337342-1200140478=:19333
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0801121421331.19333@kivilampi-30.cs.helsinki.fi>

On Sat, 12 Jan 2008, Herbert Xu wrote:

> On Sat, Jan 12, 2008 at 09:40:17AM +0000, Ilpo Järvinen wrote:
> 
> Your emails are now using UTF-8 encoding but it's still declaring
> ISO-8859-1 as the charset. 

Thanks for trying to help but my situation is such that I think it got 
also you confused (this kind of mixed encoding is beoynd my skills 
really)... :-) Besides, I wouldn't mind of having incorrect characters
in my name, I'm just used to that but somebody else wasn't that happy 
about it.

Here's one example...

From: "=?utf-8?q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
...
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

Something still needed besides these to declare email utf-8?

> So you probably want to fix that up or your name may show up as JÃ¤vinen 
> on the reader's screen.

Did you actually see this? I'd expect to see that as well but no, From is 
correctly decoded by my ISO-8859-1'ish MUA, aha, seems that I still have 
something to do to deal with the Signed-off line.

...Maybe I just fall-back to changing my last name, it's the only 
full-proof solution... ;-)

-- 
 i.
---696243703-212337342-1200140478=:19333--
