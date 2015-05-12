From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] test_bpf: add 173 new testcases for eBPF
Date: Tue, 12 May 2015 08:22:14 -0700
Message-ID: <55521AA6.7010000@plumgrid.com>
References: <1431408164-4524-1-git-send-email-ast@plumgrid.com> <5551B289.4020400@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37084 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932817AbbELPWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:22:17 -0400
Received: by igbsb11 with SMTP id sb11so17560197igb.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:22:17 -0700 (PDT)
In-Reply-To: <5551B289.4020400@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/12/15 12:58 AM, Daniel Borkmann wrote:
> On 05/12/2015 07:22 AM, Alexei Starovoitov wrote:
>> From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
>>
>> From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
>
> 'From' tag somehow slipped in twice for some reason. Downloading
> the mbox and applying it shows the second on in the git log.

hmm, that's odd.
I've actually tried to manually 'git am' the patch before sending
and it applied without extra 'From'.
But now I did 'pwclient git-am 471127' and indeed I see
an extra 'From' line.
Strange.
Sure, will respin.
