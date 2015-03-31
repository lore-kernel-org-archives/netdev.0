From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] vxlan: fix indentation
Date: Mon, 30 Mar 2015 20:09:54 -0700
Message-ID: <CAM_iQpXEh=9jMtL5=_SxmDi_Z5jRX2FyGSmNXJTLKD=X=XPW7Q@mail.gmail.com>
References: <d8d0c5dade7401c4acc2200479025f9f589404b2.1427638583.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33008 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753991AbbCaDJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 23:09:54 -0400
Received: by pacgg7 with SMTP id gg7so5702892pac.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 20:09:54 -0700 (PDT)
In-Reply-To: <d8d0c5dade7401c4acc2200479025f9f589404b2.1427638583.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 29, 2015 at 7:17 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Some lines in vxlan code are indented by 7 spaces instead of a tab.
>
> Fixes: e4c7ed415387 ("vxlan: add ipv6 support")

Non-bug-fixes don't need this, but it is harmless to have it.

> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks.
