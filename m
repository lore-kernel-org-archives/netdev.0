From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/7] ebpf: check first for MAXINSNS in bpf_prog_load
Date: Thu, 12 Feb 2015 21:43:55 +0100
Message-ID: <54DD108B.60401@iogearbox.net>
References: <cover.1423610452.git.daniel@iogearbox.net> <a1a9810494aebf0c0be8660e996b84c1cdb06444.1423610452.git.daniel@iogearbox.net> <CAMEtUuxatiqWCGeNmKEXHRFR=68L9=SnpYrnzQm-+WnRzGvtzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41085 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbbBLUoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 15:44:00 -0500
In-Reply-To: <CAMEtUuxatiqWCGeNmKEXHRFR=68L9=SnpYrnzQm-+WnRzGvtzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2015 02:21 AM, Alexei Starovoitov wrote:
...
> So if user specified 'my_ultra_long_proprietery_license'
> that should be fine. The program should still be accepted
> and marked as non-gpl.

Yep, true. Most likely I'll drop this one for non-RFC anyway
as it's not much of value. ;)
