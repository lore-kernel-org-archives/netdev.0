From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 5/5] bpf: enable verifier to better track const
 alu ops
Date: Wed, 25 Jan 2017 21:19:09 +0100
Message-ID: <5889083D.7000702@iogearbox.net>
References: <cover.1485214851.git.daniel@iogearbox.net> <41914154d137b47e3c9400da58e7e2b15ef5d43a.1485214851.git.daniel@iogearbox.net> <CALDO+Sa5w3munbMVBYGAu1mpXE0Bj9kV_E=DvPq0YtunVnQf1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ast@kernel.org, Gianluca Borello <g.borello@gmail.com>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38883 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751324AbdAYUTP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 15:19:15 -0500
In-Reply-To: <CALDO+Sa5w3munbMVBYGAu1mpXE0Bj9kV_E=DvPq0YtunVnQf1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2017 04:56 PM, William Tu wrote:
> Looks good to me, I tested with several complex program without any
> problem. Thanks for the patch.

Thanks for re-testing, William!
