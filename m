From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: add show_fdinfo handler for maps
Date: Thu, 19 Nov 2015 09:42:29 -0800
Message-ID: <20151119174228.GA4918@ast-mbp.thefacebook.com>
References: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33420 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbbKSRme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 12:42:34 -0500
Received: by pabfh17 with SMTP id fh17so90373862pab.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 09:42:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015 at 11:56:22AM +0100, Daniel Borkmann wrote:
> Add a handler for show_fdinfo() to be used by the anon-inodes
> backend for eBPF maps, and dump the map specification there. Not
> only useful for admins, but also it provides a minimal way to
> compare specs from ELF vs pinned object.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
