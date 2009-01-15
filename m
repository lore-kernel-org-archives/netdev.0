From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 10:10:15 +0000
Message-ID: <20090115101015.GD5461@ff.dom.local>
References: <20081010090426.GA6054@ff.dom.local> <496F04AB.2080705@bigtelecom.ru> <20090115095454.GA5461@ff.dom.local> <200901151157.13340.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Chris Caputo <ccaputo@alt.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:57978 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759302AbZAOKKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 05:10:21 -0500
Content-Disposition: inline
In-Reply-To: <200901151157.13340.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 11:57:13AM +0200, Denys Fedoryschenko wrote:
> I didn't notice a bug, just because all that time i was using it without 
> hrtimers (because of nmi_watchdog).
> 

Denys, maybe I forgot something, but I think you reported this bug
with nmi_watchdog too...

Jarek P.
