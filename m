From: Jeremy Harris <jgh@redhat.com>
Subject: Re: TCP fast retransmit issues
Date: Thu, 17 Aug 2017 14:20:58 +0100
Message-ID: <80a03ede-1b50-1458-a07f-c4ba886a2dda@redhat.com>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk>
 <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
 <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk>
 <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <fd335e0a0c914b9c42a754da2d24b1c3@vsen.dk> <20170726141847.GC1737@1wt.eu>
 <0b60368890bdb9aa1cf1df4bd0bf21cf@vsen.dk> <20170726143827.GD1737@1wt.eu>
 <0d41553d-69ac-651c-9c41-743391619a40@vsen.dk> <20170728072750.GA6437@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44602 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750857AbdHQNVB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 09:21:01 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 479338F505
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 13:21:01 +0000 (UTC)
Received: from lap.dom.ain (unknown [10.33.32.19])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id B36A95C552
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 13:21:00 +0000 (UTC)
In-Reply-To: <20170728072750.GA6437@1wt.eu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/07/17 08:27, Willy Tarreau wrote:
> I didn't want to suggest names but since you did it first ;-) Indeed it's
> mostly on the same device that I've been bothered a lot by their annoying
> randomization. I used to know by memory the exact command to type to disable
> it, but I don't anymore (something along "no randomization"). 

https://supportforums.cisco.com/document/48551/single-tcp-flow-performance-firewall-services-module-fwsm#TCP_Sequence_Number_Randomization_and_SACK

https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk74640

-- 
Cheers,
  Jeremy
