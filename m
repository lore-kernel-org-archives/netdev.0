From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net: core: set and refine qdisc pkt len
 before tc_classify
Date: Wed, 13 May 2015 14:42:43 -0700
Message-ID: <1431553363.27831.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431550209-3498-1-git-send-email-daniel@iogearbox.net>
	 <1431552055.27831.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, fw@strlen.de, ast@plumgrid.com,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34288 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965426AbbEMVmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 17:42:45 -0400
Received: by pdbqa5 with SMTP id qa5so63679527pdb.1
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 14:42:44 -0700 (PDT)
In-Reply-To: <1431552055.27831.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2015-05-13 at 14:20 -0700, Eric Dumazet wrote:

> 
> I noticed you did not CC me, don't be afraid to include me next time one
> of my commit is referred in a changelog ;)

Sorry, I was wrong on this ;)
