From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 4/4] soreuseport: BPF selection functional
 test
Date: Tue, 29 Dec 2015 15:51:44 -0800
Message-ID: <20151229235143.GB5396@ast-mbp.thefacebook.com>
References: <1451410150-15466-1-git-send-email-kraigatgoog@gmail.com>
 <1451410150-15466-5-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36711 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbbL2Xvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 18:51:47 -0500
Received: by mail-pa0-f45.google.com with SMTP id yy13so37880936pab.3
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2015 15:51:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1451410150-15466-5-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2015 at 12:29:10PM -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> This program will build classic and extended BPF programs and
> validate the socket selection logic when used with
> SO_ATTACH_REUSEPORT_CBPF and SO_ATTACH_REUSEPORT_EBPF.
> 
> It also validates the re-programing flow and several edge cases.
> 
> Signed-off-by: Craig Gallek <kraig@google.com>

nice test.
Acked-by: Alexei Starovoitov <ast@kernel.org>
