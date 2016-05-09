From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V3 00/10] cls_flower hardware offload support
Date: Mon, 9 May 2016 23:31:52 +0300
Message-ID: <CAJ3xEMjB5YRySTviaKzpr432MR61TnBqJdsqs8rBdfS6cSp2Dg@mail.gmail.com>
References: <1457433758-9193-1-git-send-email-amir@vadai.me>
	<20160310.162435.690159053489962918.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amir@vadai.me>,
	Linux Netdev List <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36690 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbcEIUbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 16:31:53 -0400
Received: by mail-oi0-f50.google.com with SMTP id x201so224611207oif.3
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 13:31:53 -0700 (PDT)
In-Reply-To: <20160310.162435.690159053489962918.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 12:24 AM, David Miller <davem@davemloft.net> wrote:
> From: Amir Vadai <amir@vadai.me>
> Date: Tue,  8 Mar 2016 12:42:28 +0200

>> This patchset introduces cls_flower hardware offload support over ConnectX-4
>> driver, more hardware vendors are welcome to use it too.

> Series applied, thanks for retaining detailed change history in this series
> header posting.


Hi Dave,

Amir was working lately on a follow up series which adds support to HW
statistics (packet/bytes and lastuse) for offloaded TC flower flows.
The series contains patches to TC/flower and to mlx5.

Wanted to check with you if such a submission can take place in
parallel with another net-next mlx5 only submission which is planned
by the driver team.

Thanks,

Or.
