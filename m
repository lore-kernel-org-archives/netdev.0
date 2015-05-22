From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] test_bpf: Add backward jump test case
Date: Fri, 22 May 2015 18:06:52 +0200
Message-ID: <555F541C.9010507@iogearbox.net>
References: <1432309000-11545-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41268 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946012AbbEVQG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 12:06:59 -0400
In-Reply-To: <1432309000-11545-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2015 05:36 PM, Alexei Starovoitov wrote:
> From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
>
> Currently the testsuite does not have a test case with a backward jump.
> The s390x JIT (kernel 4.0) had a bug in that area.
> So add one new test case for this now.
>
> Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
