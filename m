From: Chris Friesen <chris.friesen@windriver.com>
Subject: Re: [PATCH v2] route: do not cache fib route info on local routes
 with oif
Date: Fri, 8 Apr 2016 14:06:37 -0600
Message-ID: <57080F4D.7040101@windriver.com>
References: <5706B250.1060303@windriver.com> <alpine.LFD.2.11.1604072305400.2154@ja.home.ssi.bg> <5707C950.6060806@windriver.com> <alpine.LFD.2.11.1604082207330.2124@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55138 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754160AbcDHUGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 16:06:52 -0400
In-Reply-To: <alpine.LFD.2.11.1604082207330.2124@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2016 01:14 PM, Julian Anastasov wrote:

> 	Your patch is corrupted. I was in the same trap
> some time ago but with different client:
>
>  From Documentation/email-clients.txt:
>
> Don't send patches with "format=flowed".  This can cause unexpected
> and unwanted line breaks.
>
> 	Anyways, the change looks good to me and I'll add my
> Reviewed-by tag the next time.


Doh...forgot to turn off word wrapping.  New patch coming.

Chris
