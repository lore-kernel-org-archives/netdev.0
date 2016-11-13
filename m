From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v1] bpf: Use u64_to_user_ptr()
Date: Mon, 14 Nov 2016 00:31:48 +0100
Message-ID: <5828F7E4.6030002@iogearbox.net>
References: <20161113184403.15222-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57309 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935125AbcKMXc4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 18:32:56 -0500
In-Reply-To: <20161113184403.15222-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2016 07:44 PM, Mickaël Salaün wrote:
> Replace the custom u64_to_ptr() function with the u64_to_user_ptr()
> macro.
>
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Daniel Borkmann <daniel@iogearbox.net>

Looks good to me, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
