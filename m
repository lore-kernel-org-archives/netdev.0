From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH 1/1] xdp: Sample xdp program implementing ip forward
Date: Tue, 3 Oct 2017 09:24:44 -0700
Message-ID: <b931769a-ff3b-f6fb-a423-5a7ffb4b35bc@gmail.com>
References: <1507016225-319-1-git-send-email-Christina.Jacob@cavium.com>
 <1507016225-319-2-git-send-email-Christina.Jacob@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: cjacob <Christina.Jacob@cavium.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507016225-319-2-git-send-email-Christina.Jacob@cavium.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/3/17 12:37 AM, cjacob wrote:
> diff --git a/samples/bpf/xdp3_kern.c b/samples/bpf/xdp3_kern.c
> new file mode 100644
> index 0000000..62d905d
> --- /dev/null
> +++ b/samples/bpf/xdp3_kern.c
> @@ -0,0 +1,204 @@
> +/* Copyright (c) 2016 PLUMgrid

2016 PLUMgrid?


> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + */
> +#define KBUILD_MODNAME "
