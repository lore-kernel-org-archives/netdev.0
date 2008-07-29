From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: "MD5 Hash NOT expected but found" ..
Date: Tue, 29 Jul 2008 09:16:15 -0700
Message-ID: <20080729091615.11595272@extreme>
References: <20080729160430.GQ3820@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matti Aarnio <matti.aarnio@zmailer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:39950 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbYG2QQR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 12:16:17 -0400
In-Reply-To: <20080729160430.GQ3820@mea-ext.zmailer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Jul 2008 19:04:30 +0300
Matti Aarnio <matti.aarnio@zmailer.org> wrote:

> Dmesg reports following on  2.6.26-0.45.rc4.git2.fc10.x86_64
> 
> 
> 
> MD5 Hash NOT expected but found (207.118.50.124, 4463)->(212.16.98.133, 25)
> MD5 Hash NOT expected but found (207.118.50.124, 4463)->(212.16.98.133, 25)
> MD5 Hash NOT expected but found (64.91.108.168, 3704)->(212.16.98.133, 25)
> MD5 Hash NOT expected but found (64.91.108.168, 3704)->(212.16.98.133, 25)
> MD5 Hash NOT expected but found (69.29.208.8, 4730)->(212.16.98.133, 25)
> MD5 Hash NOT expected but found (69.29.208.8, 4730)->(212.16.98.133, 25)
> MD5 Hash NOT expected but found (69.29.208.8, 4729)->(212.16.98.133, 25)
> MD5 Hash NOT expected but found (69.29.200.106, 1223)->(212.16.98.133, 25)
> MD5 Hash NOT expected but found (69.29.200.106, 1223)->(212.16.98.133, 25)
> MD5 Hash NOT expected but found (69.29.200.106, 3316)->(212.16.98.133, 25)
> MD5 Hash NOT expected but found (69.29.200.106, 1169)->(212.16.98.133, 25)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Somebody is trying to connect with MD5 option.
This kernel message is too verbose for production systems.
