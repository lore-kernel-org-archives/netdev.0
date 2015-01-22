From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: act_bpf: fix size mismatch on filter preparation
Date: Thu, 22 Jan 2015 08:44:00 -0800
Message-ID: <CAADnVQJoSu+daDuDytM7gmApiHZyN-yTkm9ZFVCcwCOpH-Cj+A@mail.gmail.com>
References: <1421920699-26556-1-git-send-email-dborkman@redhat.com> <1421920699-26556-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:34520 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbbAVQod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 11:44:33 -0500
Received: by mail-qg0-f48.google.com with SMTP id z60so2058794qgd.7
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 08:44:32 -0800 (PST)
In-Reply-To: <1421920699-26556-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2015 at 1:58 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> Similarly as in cls_bpf, also this code needs to reject mismatches.
>
> Reference: http://article.gmane.org/gmane.linux.network/347406
> Fixes: d23b8ad8ab23 ("tc: add BPF based action")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
