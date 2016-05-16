From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf, doc: fix typo on bpf_asm descriptions
Date: Mon, 16 May 2016 14:52:55 -0700
Message-ID: <20160516215251.GA10876@ast-mbp.thefacebook.com>
References: <e99246ae5491ccf99726ca78e78d58d8c41c78e7.1463432379.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, sebastian.amend@googlemail.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33293 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbcEPVxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 17:53:00 -0400
Received: by mail-pa0-f67.google.com with SMTP id gh9so15491629pac.0
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 14:52:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <e99246ae5491ccf99726ca78e78d58d8c41c78e7.1463432379.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2016 at 11:06:53PM +0200, Daniel Borkmann wrote:
> Fix description of some of the bpf_asm tool related jump instructions
> and generally move them to format A <op> k.
> 
> Reported-by: Sebastian Amend <sebastian.amend@googlemail.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
