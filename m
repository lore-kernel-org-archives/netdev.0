From: "Jing Min Zhao" <zhaojingmin@hotmail.com>
Subject: Re: Two comments on the H.323 conntrack/NAT helper
Date: Thu, 23 Mar 2006 21:34:02 -0500
Message-ID: <BAY109-DAV187923EE24B95ED9F5B94B3DF0@phx.gbl>
References: <20060324001307.GO22727@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <netfilter-devel@lists.netfilter.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422976AbWCXCeN@vger.kernel.org>
To: "Adrian Bunk" <bunk@stusta.de>,
	"Jing Min Zhao" <zhaojignmin@hotmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


----- Original Message ----- 
From: "Adrian Bunk" <bunk@stusta.de>
To: "Jing Min Zhao" <zhaojignmin@hotmail.com>
Cc: <netdev@vger.kernel.org>; <netfilter-devel@lists.netfilter.org>; 
<linux-kernel@vger.kernel.org>
Sent: Thursday, March 23, 2006 7:13 PM
Subject: Two comments on the H.323 conntrack/NAT helper


> Two comments on the H.323 conntrack/NAT helper:
Thank you for your advice.

> - the function prototypes in ip_nat_helper_h323.c are _ugly_,
>  please move them to a header file
Correct, I'll do that.

> - is there a reason for not using EXPORT_SYMBOL_GPL?
>
No, I just forgot it. I'll change this too.

> cu
Hope I can get more advice from you.

> Adrian
>
> -- 
>
>       "Is there not promise of rain?" Ling Tan asked suddenly out
>        of the darkness. There had been need of rain for many days.
>       "Only a promise," Lao Er said.
>                                       Pearl S. Buck - Dragon Seed
>
That's Hepburn :-)

>
>
