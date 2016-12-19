From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: ovs internal_dev mtu
Date: Mon, 19 Dec 2016 10:01:47 -0800
Message-ID: <CAM_iQpVhrxUOBiF2NceufvnuSA51xMxYvM6vveD0d1t1jCdkrA@mail.gmail.com>
References: <E0899132-14F7-45F9-8F02-94421B595D4E@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: nickcooper-zhangtonghao <nic.tongh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34288 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbcLSSCJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 13:02:09 -0500
Received: by mail-qk0-f193.google.com with SMTP id t184so1223447qkd.1
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 10:02:08 -0800 (PST)
In-Reply-To: <E0899132-14F7-45F9-8F02-94421B595D4E@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2016 at 12:59 AM, nickcooper-zhangtonghao
<nic.tongh@gmail.com> wrote:
> The upstream net-next has removed the =E2=80=9Cinternal_dev_change_mtu=E2=
=80=9D.
> It will be ok for ovs(e.g. mtu_request) ? I think that code should
> be keep. Can you provide more information =EF=BC=9F

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=
=3D91572088e3fdbf4fe31cf397926d8b890fdb3237
