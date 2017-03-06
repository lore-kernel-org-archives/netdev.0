From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: disable broken write protection on i386
Date: Mon, 06 Mar 2017 22:43:03 +0100
Message-ID: <58BDD7E7.2010804@iogearbox.net>
References: <f722fcb96307fa6c449bbe2f19a4fe9797272678.1488596969.git.daniel@iogearbox.net>      <CAGXu5jJO=Nwq-ja9+yc==R2d-TAJmMv7eT4v9GYF5v8agqxUnQ@mail.gmail.com>    <58BDAC03.7040501@iogearbox.net> <20170306.105206.1890095338368427293.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, netdev@vger.kernel.org,
        fengguang.wu@intel.com, labbott@redhat.com, ast@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34115 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754240AbdCFWdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 17:33:23 -0500
In-Reply-To: <20170306.105206.1890095338368427293.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2017 07:52 PM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Mon, 06 Mar 2017 19:35:47 +0100
>
>> I can do a few more tests with the kernel I have. I'm also totally
>> fine if we drop this patch; it's just rc1, so there's plenty of time
>> till a final release.
>
> I would really prefer we get to the bottom of this rather than apply
> the quick band-aid on this one.

Ok, sounds reasonable.
