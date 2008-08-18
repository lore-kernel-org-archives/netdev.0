From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 21:05:18 +0300
Message-ID: <200808182105.19263.denys@visp.net.lb>
References: <20080818155532.GA2981@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:42605 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbYHRSGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 14:06:33 -0400
In-Reply-To: <20080818155532.GA2981@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Alas I can't find anything better for this than the previous patch
> named "03-fix_patch_2.patch" in your repository. I attach it below
> for any case (apply after all you currently had - there will be a
> little offset warning while patching). Alternatively, you can wait
> for David's opinion.
>
> Jarek P.
>
Tested 1 hour, peak time, alternative and regular shaper - no warning, no 
oops, no panic. Seems all fine for now. I will do more intensive tests 
tomorrow, including backbone units.
