From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next v2 5/5] {f,m}_bpf: add more example code
Date: Sun, 29 Nov 2015 11:56:01 -0800
Message-ID: <20151129115601.76c07295@xeon-e3>
References: <cover.1448547199.git.daniel@iogearbox.net>
	<d40d1f8668201d9a766aabef4045c6baf14aa146.1448547199.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35865 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbbK2Tzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 14:55:52 -0500
Received: by pacdm15 with SMTP id dm15so161568072pac.3
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 11:55:52 -0800 (PST)
In-Reply-To: <d40d1f8668201d9a766aabef4045c6baf14aa146.1448547199.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Nov 2015 15:38:46 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> I've added three examples to examples/bpf/ that demonstrate how one can
> implement eBPF tail calls in tc with f.e. multiple levels of nesting.
> That should act as a good starting point, but also as test cases for the
> ELF loader and kernel. A real test suite for {f,m,e}_bpf is still to be
> developed in future work.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

All applied to net-next branch.
