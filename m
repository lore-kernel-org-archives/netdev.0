From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Thu, 20 Dec 2007 22:44:59 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712202243460.20288@kivilampi-30.cs.helsinki.fi>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>
 <Pine.LNX.4.64.0712181910580.4422@fbirervta.pbzchgretzou.qr>
 <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com>
 <4768123A.7040603@cosmosbay.com>  <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
  <47682F8C.20205@cosmosbay.com>  <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com>
  <47694FCC.1020507@cosmosbay.com>  <83a51e120712190943m3bf0e2e4v2ea6b660142e9a5a@mail.gmail.com>
  <47695CEF.4090908@cosmosbay.com> <83a51e120712200808m7fa63e9jc588124a6da5f740@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Jan Engelhardt <jengelh@computergmbh.de>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Nichols <jamesnichols3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51419 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754894AbXLTUpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 15:45:01 -0500
In-Reply-To: <83a51e120712200808m7fa63e9jc588124a6da5f740@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Dec 2007, James Nichols wrote:

> > I still dont understand.
> >
> > "tcpdump -p -n -s 1600 -c 10000" doesnt reveal User data at all.
> >
> > Without any exact data from you, I am afraid nobody can help.
> 
> Oh, I didn't see that you specified specific options.  I'll still have
> to anonymize 2000+ IP addresses, but I think there is an open source
> tool that will do this for you.

Even a simple for loop in shell can do that. It's not that hard and 
there's very little need for manual work! Ingrediments: for, cut, grep
and sed.


-- 
 i.
