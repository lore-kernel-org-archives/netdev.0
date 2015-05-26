From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] test_bpf: add similarly conflicting jump test
 case only for classic
Date: Tue, 26 May 2015 20:33:42 +0200
Message-ID: <5564BC86.3030406@iogearbox.net>
References: <7e621bdbd1df285fc9685f3a068accd8bb22d429.1432661933.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49490 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbbEZSdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 14:33:44 -0400
In-Reply-To: <7e621bdbd1df285fc9685f3a068accd8bb22d429.1432661933.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/26/2015 07:45 PM, Daniel Borkmann wrote:
> While 3b52960266a3 ("test_bpf: add more eBPF jump torture cases")
> added the int3 bug test case only for eBPF, which needs exactly 11
> passes to converge, here's a version for classic BPF that would
...

Noticed a newline accidentally slipped in, please ignore this patch,
will fix it.
