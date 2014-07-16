From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 05/11] openvswitch: Add recirc action
Date: Wed, 16 Jul 2014 11:07:30 +0200
Message-ID: <1405501650.10255.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405495932-2076-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Andy Zhou <azhou@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:54801 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbaGPJHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 05:07:34 -0400
Received: by mail-we0-f175.google.com with SMTP id t60so579233wes.6
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 02:07:33 -0700 (PDT)
In-Reply-To: <1405495932-2076-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-07-16 at 00:32 -0700, Pravin B Shelar wrote:
> From: Andy Zhou <azhou@nicira.com>
> 
> Recirculation implementation for Linux kernel data path.


This is a very lame changelog if you ask me.

Does it involve recursion ?

Its really not clear reading the patch what is going on here.
