From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 master 2/2] bpf: consolidate dumps to use bpf_dump_prog_info
Date: Tue, 05 Sep 2017 18:37:11 +0200
Message-ID: <59AED2B7.2010000@iogearbox.net>
References: <cover.1504570627.git.daniel@iogearbox.net> <1e96ef342a4f34ee8c8119ee8cc1ed7092ea5ced.1504570627.git.daniel@iogearbox.net> <20170905093501.2f1fbbfc@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57420 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751774AbdIEQhP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 12:37:15 -0400
In-Reply-To: <20170905093501.2f1fbbfc@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2017 06:35 PM, Stephen Hemminger wrote:
[...]
> I applied this to master, and resolved conflicts with net-next.
> But the dump with JSON of xdp is now incomplete.

Ok, I will check it out, and send a follow-up to make it
complete again.
