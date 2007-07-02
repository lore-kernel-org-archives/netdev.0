From: Jens Stroebel <drifter@bcsoft.de>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Mon, 02 Jul 2007 12:23:14 +0200
Message-ID: <4688D212.7080609@bcsoft.de>
References: <200704162241.31729.peter.missel@onlinehome.de> <200705012119.48598.peter.missel@onlinehome.de> <20070501200723.GA19212@electric-eye.fr.zoreil.com> <200706301448.50541.peter.missel@onlinehome.de> <20070630133810.GA15951@electric-eye.fr.zoreil.com> <20070630193003.GA21140@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:55116 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbXGBKXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 06:23:19 -0400
In-Reply-To: <20070630193003.GA21140@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
>> The patch will not apply directly against 2.6.21.5. Is it an option for
>> you to try 2.6.22-rc6 or are you stuck with 2.6.21.5 ?
> 
> If you feel adventurous, you will find a compile-tested-only patchkit for
> 2.6.21.5 here:
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21.5
> or:
> http://www.fr.zoreil.com/people/francois/misc/20060630-2.6.21.5-r8169-test.patch
> 
> The content should be almost the same as the 2.6.22-rc6 patchkit dated
> from 2007/06/28 (i.e. pending 2.6.23 merge).

  Wow, great; I applied it to the kernel build this morning;
in itself, it does not stop the blocking behavior from happening.
But I will try to add the patch I mentioned in the previous messages of
which you said it shouldn't be used without applying the patchset first.

		greets,
		   jens
-- 
drifter@bcsoft.de
			23.....56.......drifting
By caffeine alone I set my mind in motion, By the beans of Java
do thoughts acquire speed,  hands acquire shaking,  the shaking
becomes a warning, By caffeine alone do I set my mind in motion
