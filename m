From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: fix trivial comment typo
Date: Tue, 03 Nov 2015 10:48:43 +0100
Message-ID: <563882FB.1010008@iogearbox.net>
References: <5636B557.1030804@gmail.com> <20151102.163138.2054202316045092354.davem@davemloft.net> <5637DA1F.6060501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, trivial@kernel.org, ast@kernel.org,
	linux-kernel@vger.kernel.org
To: Matthew Fernandez <matthew.fernandez@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54867 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbbKCJsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 04:48:47 -0500
In-Reply-To: <5637DA1F.6060501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/02/2015 10:48 PM, Matthew Fernandez wrote:
> On 03/11/15 08:31, David Miller wrote:
>> From: Matthew Fernandez <matthew.fernandez@gmail.com>
>> Date: Mon, 2 Nov 2015 11:59:03 +1100
>>
>>> bpf: fix trivial comment typo
>>>
>>> Signed-off-by: Matthew Fernandez <matthew.fernandez@gmail.com>
>>
>> This doesn't apply to any tree.
>
> I'm sorry, I think I must be missing something. This seems to apply cleanly to the current tip of mainline (e86328c489d7) to me. Was this not in the expected format? It wasn't my intention to waste your time, so I apologise for any newbie errors.

You might want to check Documentation/networking/netdev-FAQ.txt ;),
and rebase your spelling fix f.e. to the latest net-next tree.
