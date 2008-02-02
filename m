From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: kernel panic on 2.6.24 with esfq patch applied
Date: Sat, 02 Feb 2008 23:19:52 +0100
Message-ID: <47A4EC88.1010602@gmail.com>
References: <20080201131509.M52958@visp.net.lb> <47A444A8.8020304@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:16904 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbYBBWNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 17:13:42 -0500
Received: by ug-out-1314.google.com with SMTP id z38so947163ugc.16
        for <netdev@vger.kernel.org>; Sat, 02 Feb 2008 14:13:40 -0800 (PST)
In-Reply-To: <47A444A8.8020304@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corey Hickey wrote, On 02/02/2008 11:23 AM:
 ...

> I'd rather you were using my recent patches to SFQ instead of ESFQ. I
> was able to crash a 2.6.24 user-mode Linux with ESFQ as well; I don't
> know if that's what you encountered, but the SFQ patches should be
> better anyway.
> 
> http://fatooh.org/esfq-2.6/sfq-2.6.24.tar.bz2
> http://fatooh.org/esfq-2.6/

Hi Corey!

I've just had a look at your site, and see you're a bit disappointed about
the reception of your patches here. I don't use nor know about your work
(maybe some time...), and wish you better public here, but maybe you'll
find this story interesting: a few years ago, when I didn't even think of
reading netdev, I quite often visited pages of such projects as HTB (not
in every distro yet), IMQ or Julian Anastasov's. They were quite popular
subjects on admins lists, and I really admired people around these
projects, while the main kernel was something big and anonymous (no idea
e.g. about D. Miller). For the same reason I knew more about people from
iptables project - only because there was a need to visit this for some
non standard modules, and about A. Kuznetsov - only because of patching
iproute for HTB!!! (Only later I found that Alexey did more than needed
for several such HTBs.) So, it seems there could be good side of such
unofficial status too - if you only have something really useful for
others...

Cheers,
Jarek P.
