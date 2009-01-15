From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 12:40:33 +0200
Message-ID: <200901151240.33967.denys@visp.net.lb>
References: <20081010090426.GA6054@ff.dom.local> <200901151157.13340.denys@visp.net.lb> <20090115101015.GD5461@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Chris Caputo <ccaputo@alt.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:56554 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757860AbZAOKkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 05:40:46 -0500
In-Reply-To: <20090115101015.GD5461@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, you are correct, on another hardware. Thats strange.

On Thursday 15 January 2009 12:10:15 Jarek Poplawski wrote:
>
> Denys, maybe I forgot something, but I think you reported this bug
> with nmi_watchdog too...
>
> Jarek P.


