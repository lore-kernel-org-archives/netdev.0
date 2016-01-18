From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next 0/2] BPF update
Date: Mon, 18 Jan 2016 11:43:53 -0800
Message-ID: <20160118114353.36ab1fa7@xeon-e3>
References: <cover.1452559602.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34817 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756213AbcARTnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 14:43:45 -0500
Received: by mail-pf0-f170.google.com with SMTP id 65so162193304pff.2
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2016 11:43:45 -0800 (PST)
In-Reply-To: <cover.1452559602.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jan 2016 02:03:06 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Two small BPF frontend updates.
> 
> The patchset is against your current net-next branch (pre master merge).
> 
> Thanks!
> 
> Daniel Borkmann (2):
>   tc, bpf: check section names and type everywhere
>   tc, bpf: more header checks on loading elf
> 
>  tc/tc_bpf.c | 64 +++++++++++++++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 58 insertions(+), 6 deletions(-)

This applies fine to master. Accepted.
