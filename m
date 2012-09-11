From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: CBQ(but probably u32 filter bug), kernel "freeze", at least
 from 3.2.0
Date: Wed, 12 Sep 2012 01:50:09 +0300
Message-ID: <ceeee25e4588b250ce7b363afe97a489@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:41560 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab2IKWuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 18:50:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>No problem, I reproduced the bug on my dev machine, but its always
>better to have bug reporter adding its own 'Tested-by:' tag ;)
>
>Thanks
Tested-by: Denys Fedoryschenko <denys@visp.net.lb>

Thank you a lot, it fixes the problem!

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
