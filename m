From: Gabriel C <nix.or.die@googlemail.com>
Subject: Re: [PATCH] NET_CLS_RSVP6 should depend on IPV6
Date: Sat, 14 Jul 2007 20:29:42 +0200
Message-ID: <46991616.8070509@googlemail.com>
References: <4698A7B6.1030302@googlemail.com> <4698ED6E.6020502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:46803 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759461AbXGNSaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 14:30:09 -0400
Received: by ug-out-1314.google.com with SMTP id j3so753347ugf
        for <netdev@vger.kernel.org>; Sat, 14 Jul 2007 11:30:08 -0700 (PDT)
In-Reply-To: <4698ED6E.6020502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Gabriel C wrote:
>   
>> cls_rsvp6 only works with IPV6 enabled kernels and IMO it should depends
>> on IPV6.
>>     
>
>
> I can't see any functional dependency on IPv6, what exactly are you
> refering to? People might want to use it on a bridge for example
> without having IPv6 running locally.
>
>   

I didn't knew it can be used with bridges , in this case just ignore the
patch and sorry for the noise.


Regards,

Gabriel
