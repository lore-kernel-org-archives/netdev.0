From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC] get_compat_bpf_fprog(): don't copyin field-by-field
Date: Mon, 10 Jul 2017 21:04:49 +0200
Message-ID: <5963CFD1.1010600@iogearbox.net>
References: <20170708182100.GR10672@ZenIV.linux.org.uk> <20170708182249.GT10672@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49409 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752088AbdGJTEy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 15:04:54 -0400
In-Reply-To: <20170708182249.GT10672@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2017 08:22 PM, Al Viro wrote:
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

(Looks like ppp_sock_fprog_ioctl_trans() is another such candidate.)
