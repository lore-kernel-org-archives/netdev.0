From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/3] sched: cls_bpf: fix panic on filter replace
Date: Fri, 17 Jul 2015 23:07:12 +0200
Message-ID: <55A96E80.3050406@iogearbox.net>
References: <cover.1437163466.git.daniel@iogearbox.net> <094e34b7e8d45a323c5cf18a366665654b3f3e45.1437163466.git.daniel@iogearbox.net> <55A96E05.2090002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, jiri@resnulli.us, jhs@mojatatu.com,
	edumazet@google.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58600 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754082AbbGQVHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 17:07:23 -0400
In-Reply-To: <55A96E05.2090002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2015 11:05 PM, John Fastabend wrote:
...
> Thanks Daniel. Apparently I got this right in cls_basic but botched it
> here and in cls_flow.

Yep, it's correct there. :)

Thanks,
Daniel
