From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 1/2] cls_bpf: introduce integrated actions
Date: Fri, 18 Sep 2015 14:51:34 +0200
Message-ID: <55FC08D6.9050405@iogearbox.net>
References: <1442383543-4720-1-git-send-email-ast@plumgrid.com> <1442383543-4720-2-git-send-email-ast@plumgrid.com> <55FAB40E.304@mojatatu.com> <55FABC7B.6060502@iogearbox.net> <55FAD9F4.1010603@plumgrid.com> <55FBFFF8.3050101@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55904 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753363AbbIRMvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 08:51:41 -0400
In-Reply-To: <55FBFFF8.3050101@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

On 09/18/2015 02:13 PM, Jamal Hadi Salim wrote:
...
> The architecture is about small tools that come together to
> provide complex processing. ebpf may be the best classifier
> today - but by no means the only one or guaranteed that nothing
> better will exist for speficic use cases.

Yes, I agree, I think nobody claimed that, and it also doesn't
limit anyone from their choices of configuration possibilities
one can do nowadays.

> If there is something in the core that needs improvement
> for the benefit of all, then lets do that.

Yeah, I think i.e. since the last couple of months that is already
happening from various people.

Thanks,
Daniel
