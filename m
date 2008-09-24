From: Antonio Gallo <agx@linux.it>
Subject: Re: r8169, linux kernel 2.6.22.9, broken negotiation
Date: Wed, 24 Sep 2008 09:01:14 +0200
Message-ID: <48D9E5BA.6050406@linux.it>
References: <48D8B60F.8060102@linux.it> <20080923204453.GA12519@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shuchen@realtek.com.tw, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpd4.aruba.it ([62.149.128.209]:37191 "HELO smtp3.aruba.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752792AbYIXHBT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 03:01:19 -0400
In-Reply-To: <20080923204453.GA12519@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu ha scritto:
> Antonio Gallo <agx@linux.it> :
> [...]
>> Should i try the r8168.ko from the realtek web site instead of the kernel 
>> module r8169 ?
> 
> I think that it is fixed by commit 66ec5d4fb1ce6f0bd9df4bc4b758f0916d9f37ab
> in mainline (merged between 2.6.23 and 2.6.24).
> 
> You can either use Realtek's driver or try a recent 2.6.27-rc, optionally
> patched with http://userweb.kernel.org/~romieu/r8169/2.6.27-rc6/
> 

Thanks i've tryed r8168.ko meanwhile, ethtool is perfect but the problem
is the same.

I'll try to check the commit/patches you mentioned.

Thank you so much for answering, Antonio Gallo


