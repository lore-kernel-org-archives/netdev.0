From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] neigh: check error pointer instead of NULL for ipv4_neigh_lookup()
Date: Thu, 25 Sep 2014 09:18:32 -0700
Message-ID: <CAM_iQpVk4sM2DM=pFKc1q=Ry_PKCs=6r1t9JYxkZYjpCGvtHTg@mail.gmail.com>
References: <1411603673-19084-1-git-send-email-xiyou.wangcong@gmail.com>
	<CAADnVQ+=yuG0+0kSj291MbbxMRvmeYN7D_2PkJsjkLWtnkt4WQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:37061 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813AbaIYQSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 12:18:34 -0400
Received: by mail-vc0-f172.google.com with SMTP id hy10so8227312vcb.17
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 09:18:33 -0700 (PDT)
In-Reply-To: <CAADnVQ+=yuG0+0kSj291MbbxMRvmeYN7D_2PkJsjkLWtnkt4WQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2014 at 8:35 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> assuming symptoms of this was a crash?

No.

> Or was it spotted just by code inspection?

Yes.
