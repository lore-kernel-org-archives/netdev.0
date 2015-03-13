From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/2] ebpf: add helper for obtaining current processor
 id
Date: Fri, 13 Mar 2015 18:08:07 +0100
Message-ID: <55031977.40408@iogearbox.net>
References: <cover.1426249641.git.daniel@iogearbox.net> <870dce5d9b480d267c8b3de77bad1875adc6016c.1426249641.git.daniel@iogearbox.net> <55031933.6010507@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49121 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbbCMRIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 13:08:11 -0400
In-Reply-To: <55031933.6010507@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2015 06:06 PM, Alexei Starovoitov wrote:
...
> same comment as in other patch:
> could you rename it to BPF_FUNC_get_smp_processor_id ?

Will do, yep.
