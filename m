From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Sun, 28 Aug 2016 07:48:06 -0700
Message-ID: <20160828144804.GA48090@ast-mbp.thefacebook.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33758 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752371AbcH1OsK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 10:48:10 -0400
Received: by mail-pf0-f182.google.com with SMTP id y134so43243132pfg.0
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 07:48:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 28, 2016 at 08:19:16AM -0400, Jamal Hadi Salim wrote:
> --- /dev/null
> +++ b/include/uapi/linux/tc_act/tc_skbmod.h
> @@ -0,0 +1,49 @@
> +/*
> + * Copyright (c) 2016, Jamal Hadi Salim
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + *
> + * You should have received a copy of the GNU General Public License along with
> + * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
> + * Place - Suite 330, Boston, MA 02111-1307 USA.

the address is incorrect.
That's why it's recommended to skip this section in all headers.
First paragraph in the above 'This program is ... GPL' would have been enough.
