From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Thu, 23 Apr 2015 09:13:36 +0200
Message-ID: <55389BA0.2030801@iogearbox.net>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>	<1429644476-8914-3-git-send-email-ast@plumgrid.com>	<CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com>	<55381F14.4070708@plumgrid.com> <CAHA+R7Mz0LSZ-S=k7rvUuhXm+GT9w2ve6Ug+YPJ4vqnsrLnfpw@mail.gmail.com> <55385D0B.5030103@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46697 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbbDWHNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 03:13:50 -0400
In-Reply-To: <55385D0B.5030103@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2015 04:46 AM, Alexei Starovoitov wrote:
...
> The other two threads degenerated into non-technical comments.

Yep. :-/

> Anyway, this set was RFC to answer my main question whether I should
> continue with tc cleanup or stop right here. I got my answer.

I think it's worth proceeding with this, it's long overdue.
