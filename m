From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v4 net-next 4/4] soreuseport: BPF selection functional
 test
Date: Mon, 4 Jan 2016 14:55:27 -0800
Message-ID: <20160104225526.GB34405@ast-mbp.thefacebook.com>
References: <1451947308-7867-1-git-send-email-kraigatgoog@gmail.com>
 <1451947308-7867-5-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33261 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012AbcADWzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 17:55:19 -0500
Received: by mail-pf0-f171.google.com with SMTP id q63so173039506pfb.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 14:55:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1451947308-7867-5-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 04, 2016 at 05:41:48PM -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> This program will build classic and extended BPF programs and
> validate the socket selection logic when used with
> SO_ATTACH_REUSEPORT_CBPF and SO_ATTACH_REUSEPORT_EBPF.
> 
> It also validates the re-programing flow and several edge cases.
> 
> Signed-off-by: Craig Gallek <kraig@google.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
