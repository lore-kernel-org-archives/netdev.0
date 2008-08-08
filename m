From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Fri, 8 Aug 2008 12:56:50 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808081005440.4378@wrl-59.cs.helsinki.fi>
References: <47EA0DAB.7080205@securenet.de> <200808071450.43552.denys@visp.net.lb>
 <Pine.LNX.4.64.0808071454580.4551@wrl-59.cs.helsinki.fi>
 <200808071523.04586.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-928389113-1218180059=:4378"
Cc: "=?ISO-8859-1?Q?D=E2niel_Fraga?=" <fragabr@gmail.com>,
	Thomas Jarosch <thomas.jarosch@intra2net.com>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48830 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969AbYHHJ4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 05:56:53 -0400
In-Reply-To: <200808071523.04586.denys@visp.net.lb>
Content-ID: <Pine.LNX.4.64.0808081256330.4551@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-928389113-1218180059=:4378
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0808081256331.4551@wrl-59.cs.helsinki.fi>

On Thu, 7 Aug 2008, Denys Fedoryshchenko wrote:

> On Thursday 07 August 2008, Ilpo Järvinen wrote:
> >
> > I could have still looked to it :-), I can mostly decide anything TCP
> > congestion control related based on solely a tcpdump, and I can even read
> > tcpdump -n -r logfile output if you want to fully hide any payloads (as
> > long as the lines are not split to a mess in an email :-)) though then
> > plotting them is not as easy for me (I could hack my tool someday though
> > to handle that as well).
>
> I will try my best to reproduce it and report (sure on latest stable kernel).
> On pre and git a bit more difficult but i will try also.

I thought it was "trivial to reproduce"... :-) Perhaps it was then just 
related to pre-2.6.25.7 kernels?

-- 
 i.
---696208474-928389113-1218180059=:4378--
