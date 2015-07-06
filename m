From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer in __netdev_pick_tx()
Date: Mon, 06 Jul 2015 19:36:32 +0200
Message-ID: <1436204192.4571.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <559A3B9C.90905@oracle.com>
	 <1436179279.25714.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <559A62CA.2000006@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel <xen-devel@lists.xenproject.org>
To: Bob Liu <bob.liu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36920 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbbGFRgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 13:36:36 -0400
Received: by wiclp1 with SMTP id lp1so28141337wic.0
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 10:36:35 -0700 (PDT)
In-Reply-To: <559A62CA.2000006@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-07-06 at 19:13 +0800, Bob Liu wrote:

> 
> Thank you for the quick fix!
> Tested by rebooting several times and didn't hit this panic any more.

Thanks Bob, I will submit an official patch then ;)
