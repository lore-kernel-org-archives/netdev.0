From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Tue, 26 Aug 2008 14:32:08 +0300
Message-ID: <200808261432.08594.denys@visp.net.lb>
References: <20080826095126.GA2609@ff.dom.local> <200808261416.32315.denys@visp.net.lb> <20080826113213.GA5991@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:46105 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbYHZLdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:33:36 -0400
In-Reply-To: <20080826113213.GA5991@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 26 August 2008, Jarek Poplawski wrote:

> So maybe you could try again this htb patch for limiting
> qdisc_watchdog_schedule()?
>
> Jarek P.
Yes, and i am going to take snapshops from system load with different boot 
flags. It will take time but, cause it is major router.

