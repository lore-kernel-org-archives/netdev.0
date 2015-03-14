From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] ebpf: add prandom helper for packet sampling
Date: Sat, 14 Mar 2015 01:11:20 +0100
Message-ID: <55037CA8.6080103@iogearbox.net>
References: <cover.1426249641.git.daniel@iogearbox.net> <83348b7717b2f044140539fc7faa36bebcc3da58.1426249641.git.daniel@iogearbox.net> <55031730.5030303@plumgrid.com> <55031860.20903@iogearbox.net> <55036856.1040309@iogearbox.net> <55036A7D.7050402@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53546 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbCNALY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 20:11:24 -0400
In-Reply-To: <55036A7D.7050402@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2015 11:53 PM, Alexei Starovoitov wrote:
...
> So my vote is for BPF_FUNC_get_prandom_u32 that returns
> prandom_u32() and nothing else.

I'll go for that. Occam's razor. ;)
