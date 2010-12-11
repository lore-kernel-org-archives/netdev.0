From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] isdn: return -EFAULT if copy_from_user() fails
Date: Sat, 11 Dec 2010 08:07:20 +0300
Message-ID: <20101211050720.GF10623@bicker>
References: <20101211014154.3157588b@absol.kitzblitz>
 <20101210.164721.85429801.davem@davemloft.net>
 <20101210.165003.267942493.davem@davemloft.net>
 <20101210.165259.22054320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nikai@nikai.net, isdn@linux-pingi.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57695 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777Ab0LKFHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 00:07:41 -0500
Content-Disposition: inline
In-Reply-To: <20101210.165259.22054320.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >>> Ahem, we're printing this return value:
> >>> 

Doh!  Thanks for that guys.

regards,
dan carpenter
