From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] dscc4: Undefined signed int shift
Date: Sat, 6 Feb 2016 10:59:06 +0100
Message-ID: <20160206095906.GA27167@electric-eye.fr.zoreil.com>
References: <20160206014624.GA20990@thinkpad.swarthmore.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Michael McConville <mmcco@mykolab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34728 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbcBFJ7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 04:59:10 -0500
Content-Disposition: inline
In-Reply-To: <20160206014624.GA20990@thinkpad.swarthmore.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael McConville <mmcco@mykolab.com> :
> My analysis in the below mail applies, although the second part is
> unnecessary because i isn't used in arithmetic operations here:
> 
> https://marc.info/?l=openbsd-tech&m=145377854103866&w=2
> 
> Thanks for your time.

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

For all practical matters it doesn't necessarily deserves to be fed
through stable.

-- 
Ueimor
