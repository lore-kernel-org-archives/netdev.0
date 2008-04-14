From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Reporting bugs and bisection
Date: Mon, 14 Apr 2008 13:38:02 -0700
Message-ID: <20080414133802.4535e4da.akpm@linux-foundation.org>
References: <47FEADCB.7070104@rtr.ca>
	<20080413121831.d89dd424.akpm@linux-foundation.org>
	<20080413202118.GA29658@2ka.mipt.ru>
	<200804132233.50491.rjw@sisk.pl>
	<20080413205406.GA9190@2ka.mipt.ru>
	<48028830.6020703@earthlink.net>
	<alpine.DEB.1.10.0804131546370.9318@asgard>
	<20080414043939.GA6862@1wt.eu>
	<20080414053943.GU9785@ZenIV.linux.org.uk>
	<20080413232441.e216a02c.akpm@linux-foundation.org>
	<4803ACE5.4020502@keyaccess.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, w@1wt.eu, david@lang.hm,
	sclark46@earthlink.net, johnpol@2ka.mipt.ru, rjw@sisk.pl,
	tilman@imap.cc, Valdis.Kletnieks@vt.edu, lkml@rtr.ca,
	davem@davemloft.net, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, git@vger.kernel.org,
	netdev@vger.kernel.org
To: Rene Herman <rene.herman@keyaccess.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55857 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751932AbYDNUi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 16:38:56 -0400
In-Reply-To: <4803ACE5.4020502@keyaccess.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Apr 2008 21:13:41 +0200
Rene Herman <rene.herman@keyaccess.nl> wrote:

> Does that mean you're not going to take patches that align the right end of 
> lines in comments? :-(

erm, was that ":-(" supposed to be a ":-)"?

I don't like to merge patches which fix typos and spellos and grammaros
in comments, simply because I'd be buried in the things.  I do take such
fixes for user-visible text (Documentation/, kerneldoc comments and
printks).

Right-justification of comments would fall rather a long way below spelling
fixes.

