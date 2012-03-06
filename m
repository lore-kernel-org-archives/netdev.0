From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] net: make CONFIG_BQL actually end user configurable
Date: Mon, 5 Mar 2012 23:17:43 -0500
Message-ID: <CAP=VYLquLve9prZ+++NPbwivHLbB4rP8O5ULFnTnzn-Pxjducw@mail.gmail.com>
References: <1331005096-12332-1-git-send-email-paul.gortmaker@windriver.com>
	<4F558E6E.4000707@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, davem@davemloft.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:38651 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964955Ab2CFERo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 23:17:44 -0500
Received: by pbcun15 with SMTP id un15so3586548pbc.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 20:17:43 -0800 (PST)
In-Reply-To: <4F558E6E.4000707@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 5, 2012 at 11:11 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> On 3/5/2012 7:38 PM, Paul Gortmaker wrote:

[...]

>>
>> [Apologies if this was explicitly blocked for a reason; I couldn't
>> =A0find a reason after searching netdev or threads at bufferbloat.ne=
t ]
>>
>
> It was intentional "The Kconfig entry and option is merely for
> expressing internal dependencies,". See the comments in the patch

Thanks Dave and John.  Something told me this wasn't by accident, but
somehow I still managed to overlook this in my search.  :(

Paul.
--

>
> http://patchwork.ozlabs.org/patch/128727/
>
> And corresponding mail,
>
> http://lists.openwall.net/netdev/2011/12/01/130
>
> .John
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
