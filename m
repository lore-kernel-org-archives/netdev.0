From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [2.6.25-rc5-mm1] regression: cannot run Postfix sendmail command
 as non-root
Date: Mon, 17 Mar 2008 14:17:06 +0100
Message-ID: <47DE6F52.6000006@fr.ibm.com>
References: <20080311011434.ad8c8d7d.akpm@linux-foundation.org> <47D98510.60801@imap.cc> <47D9A8DF.30809@fr.ibm.com> <47D9C1F0.6050803@imap.cc> <47DE4B7B.9040504@fr.ibm.com> <47DE6CC7.2000405@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:41000 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbYCQNUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 09:20:11 -0400
In-Reply-To: <47DE6CC7.2000405@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tilman Schmidt wrote:
> Daniel Lezcano schrieb:
> 
>> I was not able to reproduce it, but I think I didn't configured 
>> postfix as I should had. What version do you use ?
> 
> It's the one that comes with openSUSE 10.3:
> 
> ts@xenon:~> rpm -q postfix
> postfix-2.4.5-20.2
> 
>> If I may ask you, can you put your postfix configuration file and a 
>> strace -f of your failing command ? on your website, that will help me 
>> a lot to investigate.
> 
> Sure, no problem. You may find them at
> 
> http://gollum.phnxsoft.com/~ts/linux/main.cf
> http://gollum.phnxsoft.com/~ts/linux/strace.log

Thank you very much,  I will try to reproduce it with a simple program.
