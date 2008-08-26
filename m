From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Tue, 26 Aug 2008 14:16:32 +0300
Message-ID: <200808261416.32315.denys@visp.net.lb>
References: <20080826095126.GA2609@ff.dom.local> <20080826110746.GC2609@ff.dom.local> <20080826111545.GD2609@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:38084 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbYHZLSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:18:00 -0400
In-Reply-To: <20080826111545.GD2609@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 26 August 2008, Jarek Poplawski wrote:
> Hmm.. it isn't actually answer to your question, sorry. As I said
> before I think we need to have more people interested in using such
> additional options, and btw. I understood from your message that
> disabling htb didn't solve the problem?
>
> Jarek P.
Only HTB - no. If i disable softlockup debug - seems the load is less (i must 
make sure), and if i remove HTB - it is becoming low. I will try to give 
exact numbers in recent days.

