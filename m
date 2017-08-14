From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute PATCH 51/51] lib/bpf: Check return value of write()
Date: Mon, 14 Aug 2017 22:35:01 +0200
Message-ID: <59920975.7080500@iogearbox.net>
References: <20170812120510.28750-1-phil@nwl.cc> <20170812120510.28750-52-phil@nwl.cc> <59916AB3.1010001@iogearbox.net> <20170814172526.GW16375@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42599 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbdHNUfP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 16:35:15 -0400
In-Reply-To: <20170814172526.GW16375@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2017 07:25 PM, Phil Sutter wrote:
[...]
> But I really think we shouldn't make such a fuss about it - writing to
> stderr either always works or we're in trouble everywhere. This patch
> was merely to shut gcc up, so no need to waste much energy on a scenario
> which won't happen anyway.

Yup, fair enough, makes sense.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
