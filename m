From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v1] bpf: Use u64_to_user_ptr()
Date: Sun, 13 Nov 2016 18:38:57 -0800
Message-ID: <20161114023856.GA94347@ast-mbp.thefacebook.com>
References: <20161113184403.15222-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Daniel Borkmann <daniel@iogearbox.net>
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34949 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965036AbcKNCjC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 21:39:02 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so7668681pga.2
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 18:39:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161113184403.15222-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 13, 2016 at 07:44:03PM +0100, Mickaël Salaün wrote:
> Replace the custom u64_to_ptr() function with the u64_to_user_ptr()
> macro.
> 
> Signed-off-by: Mickaël Salaün <mic@digikod.net>

Thanks for following up on this one.
Acked-by: Alexei Starovoitov <ast@kernel.org>
