From: Chris Clayton <chris2553@googlemail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Tue, 18 Sep 2012 15:44:10 +0100
Message-ID: <505888BA.60502@googlemail.com>
References: <5057455A.7050108@googlemail.com> <50588371.40103@googlemail.com> <505885DC.1060006@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48720 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758172Ab2IROoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 10:44:01 -0400
Received: by eekc1 with SMTP id c1so3990507eek.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 07:44:00 -0700 (PDT)
In-Reply-To: <505885DC.1060006@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
> Sorry, I forgot to say that I also have tried running TinyCore Linux as
> a KVM guest on a 3.6.0-rc6 kernel, and I can ping the router fine, so
> the problem seems to be something specifically related to ruuning
> Windows XP as the guest. I don't have any other guests installed so
> that's as much as I can say, although I could maybe install a Win7 guest
> tomorrow if that would help.
>

Sorry again, but ignore the message above, please. Wrong kernel used in 
test. In fact, I get the same failure to ping the router running on a 
6.6.0-rc6 kernel.

Apologies for the noise.

Chris
