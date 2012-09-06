From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: CBQ(but probably u32 filter bug), kernel "freeze", at least
 from 3.2.0
Date: Thu, 06 Sep 2012 15:56:37 +0200
Message-ID: <1346939797.2484.42.camel@edumazet-glaptop>
References: <a680a8297b2f099eb713b266792b9b82@visp.net.lb>
	 <1346151568.3001.20.camel@edumazet-glaptop>
	 <1346920806.13121.180.camel@edumazet-glaptop>
	 <3012b13d6556b629a84089b68bce9a6b@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58783 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab2IFN4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 09:56:42 -0400
Received: by eaac11 with SMTP id c11so552900eaa.19
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 06:56:41 -0700 (PDT)
In-Reply-To: <3012b13d6556b629a84089b68bce9a6b@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-06 at 16:47 +0300, Denys Fedoryshchenko wrote:

> Dear Eric
> 
> Very sorry for delay, most of time in desert, without decent internet.
> I will try to test today or tomorrow.

No problem, I reproduced the bug on my dev machine, but its always
better to have bug reporter adding its own 'Tested-by:' tag ;)

Thanks
