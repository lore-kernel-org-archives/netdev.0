From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] ebpf: bpf_map_*: fix linker error on avr32 and
 openrisc arch
Date: Fri, 06 Mar 2015 08:35:54 +0100
Message-ID: <54F958DA.3080003@iogearbox.net>
References: <dc0fc4f224a95f2a9813079229cb9cc0ac069d52.1425594286.git.daniel@iogearbox.net> <CAJ3xEMgyiurkgaUwU7utcG+qdRD6k5SfS8Vsebf=fH_8-pYW0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46025 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbbCFHgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 02:36:10 -0500
In-Reply-To: <CAJ3xEMgyiurkgaUwU7utcG+qdRD6k5SfS8Vsebf=fH_8-pYW0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2015 08:20 AM, Or Gerlitz wrote:
> On Fri, Mar 6, 2015 at 12:27 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
...
>> Fixes: d4052c4aea0c ("ebpf: remove CONFIG_BPF_SYSCALL ifdefs in socket filter code")
>
> isn't that a 4.0-rc commit? if this is the case, this is for net, not net-next

Nope, that commit is only in net-next.
