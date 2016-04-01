From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around __sk_dst_get
Date: Fri, 01 Apr 2016 20:36:56 +0200
Message-ID: <56FEBFC8.6000702@iogearbox.net>
References: <20160401042655.GA16500@ast-mbp.thefacebook.com>	<56FDFA0F.5070104@stressinduktion.org>	<56FE2CE3.9080805@iogearbox.net> <20160401.143358.1963393066215816255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	sasha.levin@oracle.com, mkubecek@suse.cz
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35570 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbcDAShB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 14:37:01 -0400
In-Reply-To: <20160401.143358.1963393066215816255.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/2016 08:33 PM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Fri, 01 Apr 2016 10:10:11 +0200
>
>> Dave, do you need me to resubmit this one w/o changes:
>> http://patchwork.ozlabs.org/patch/603903/ ?
>
> I'll apply this and queue it up for -stable, thanks.

Ok, thanks!
