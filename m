From: Andi Kleen <ak@suse.de>
Subject: Re: Virtual device lo asks to queue packet! since -git15 II
Date: Sat, 21 Jul 2007 18:49:30 +0200
Message-ID: <200707211849.30469.ak@suse.de>
References: <200707210949.22880.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60277 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750933AbXGUQth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2007 12:49:37 -0400
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 632CC21662
	for <netdev@vger.kernel.org>; Sat, 21 Jul 2007 18:49:36 +0200 (CEST)
In-Reply-To: <200707210949.22880.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 21 July 2007 09:49:22 Andi Kleen wrote:
> 
> FYI
> 
> Since -git15 (probably David's merge) I see a lot of 
> 
> Virtual device lo asks to queue packet!
> Virtual device lo asks to queue packet!
> Virtual device lo asks to queue packet!
> Virtual device lo asks to queue packet!
> Virtual device lo asks to queue packet!
> Virtual device lo asks to queue packet!
> 
> during a LTP run on a nfsroot system


... and my firefox just hung itself up trying to connect to localhost:111
(in -git16 now)

Network definitely seems to have issues

-Andi

