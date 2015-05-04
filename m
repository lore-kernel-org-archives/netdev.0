From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -master] tc: {m,f}_ebpf: add option for dumping
 verifier log
Date: Mon, 4 May 2015 08:46:46 -0700
Message-ID: <20150504084646.683d8efd@urahara>
References: <b312101ba95af54ffd2f4c56694c0b44ccbfa051.1430220466.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34849 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbbEDPqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 11:46:42 -0400
Received: by pabtp1 with SMTP id tp1so163988287pab.2
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 08:46:42 -0700 (PDT)
In-Reply-To: <b312101ba95af54ffd2f4c56694c0b44ccbfa051.1430220466.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Apr 2015 13:37:42 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Currently, only on error we get a log dump, but I found it useful when
> working with eBPF to have an option to also dump the log on success.
> Also spotted a typo in a header comment, which is fixed here as well.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@plumgrid.com>

Applied thanks
