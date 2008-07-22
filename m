From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NMI lockup, 2.6.26 release
Date: Tue, 22 Jul 2008 22:35:29 +0200
Message-ID: <48864491.3010905@gmail.com>
References: <200807222142.23710.denys@visp.net.lb> <48863F5A.9080104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:63346 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbYGVUfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 16:35:06 -0400
Received: by nf-out-0910.google.com with SMTP id d3so753342nfc.21
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 13:35:05 -0700 (PDT)
In-Reply-To: <48863F5A.9080104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 07/22/2008 10:13 PM:

> denys@visp.net.lb wrote, On 07/22/2008 08:42 PM:
> 
>> workload: ifb shapers, HTB, nat, 1 e1000, 3 e100 (heavily used only two e100)
>>
> 
> 
> Maybe it's unconnected but I'd recommend to try this fresh patch for
> possible problems with e1000e vs. netconsole:
> 
> http://permalink.gmane.org/gmane.linux.network/100581
 

...and if you have TSO enabled, here is another "maybe unconnected"
recommendation:

http://permalink.gmane.org/gmane.linux.network/99585

Jarek P.

