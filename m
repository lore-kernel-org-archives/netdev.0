From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] bpf: remove reference to sock_filter_ext from
 kerneldoc comment
Date: Tue, 18 Apr 2017 10:50:13 -0700
Message-ID: <c1252748-eda5-98f0-6d69-14307a533d48@fb.com>
References: <20170418092700.9157-1-tklauser@distanz.ch>
 <58F5DDB2.8050308@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <daniel@iogearbox.net>,
        Tobias Klauser <tklauser@distanz.ch>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44302 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753784AbdDRRur (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:50:47 -0400
In-Reply-To: <58F5DDB2.8050308@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/17 2:34 AM, Daniel Borkmann wrote:
> On 04/18/2017 11:27 AM, Tobias Klauser wrote:
>> struct sock_filter_ext didn't make it into the tree and is now called
>> struct bpf_insn. Reword the kerneldoc comment for bpf_convert_filter()
>> accordingly.
>>
>> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
>
> Good point, thanks!
>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

good ol' days :)
let it rip.

Acked-by: Alexei Starovoitov <ast@kernel.org>
