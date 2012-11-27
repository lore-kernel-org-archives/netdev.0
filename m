From: Chen Gang <gang.chen@asianux.com>
Subject: Re: Fwd: Re: [PATCH] net: ipv6: change %8s to %s for rt->dst.dev->name
 in seq_printf of rt6_info_route
Date: Tue, 27 Nov 2012 13:40:53 +0800
Message-ID: <50B45265.9070303@asianux.com>
References: <50ADE447.8030300@asianux.com> <50AEEF08.4000707@asianux.com> <50B430B5.1080700@gmail.com> <50B43F12.1090709@asianux.com> <50B44563.8060905@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:48672 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658Ab2K0Fj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 00:39:58 -0500
In-Reply-To: <50B44563.8060905@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>   I think (only for my thought, maybe not correct):
>     for user input through /proc/* are all for os api level, not for "User Experience".
>     for most of outputs to user through /proc/*, are "User Experience".
> 

  and now I think what I said above is incorrect.

and now, I think:
  A) both input and output through /proc/* are for os api level.
  B) but both %8s and %s do not change the output interface format (including contents, topology, separator mark, space redundancy).
  C) so it is belong to 'User Experience', not belong to os api.

  welcome any another members to giving suggestions and completions.

  thanks.

  :-)

-- 
Chen Gang

Asianux Corporation
