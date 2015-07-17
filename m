From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 0/3] Couple of classifier fixes
Date: Fri, 17 Jul 2015 14:01:16 -0700
Message-ID: <55A96D1C.3010104@gmail.com>
References: <cover.1437163466.git.daniel@iogearbox.net> <55A96874.3030605@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, jiri@resnulli.us, jhs@mojatatu.com,
	edumazet@google.com, netdev@vger.kernel.org,
	john.r.fastabend@intel.com
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:36028 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbbGQVA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 17:00:59 -0400
Received: by obnw1 with SMTP id w1so72775620obn.3
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 14:00:59 -0700 (PDT)
In-Reply-To: <55A96874.3030605@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-07-17 01:41 PM, Daniel Borkmann wrote:
> On 07/17/2015 10:38 PM, Daniel Borkmann wrote:
>> This fixes a couple of panics in the form of (analogous for
>> cls_flow{,er}):
> 
> [ Also putting John into Cc for these fixes as it has to do with all
>   the RCU conversion, sorry just realized that after git send-email. ]
> 

No problem. Thanks a lot for cleaning it up for me.

.John
