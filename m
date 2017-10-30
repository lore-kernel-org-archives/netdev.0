From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: More painful merges...
Date: Mon, 30 Oct 2017 08:45:57 -0700
Message-ID: <18504140-3512-7e24-891c-ad9ba5ae9cec@gmail.com>
References: <20171030.211551.790664985307439262.davem@davemloft.net>
 <20171030151429.mdcvyxflhmrtvfah@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, jiri@mellanox.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:48773 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932128AbdJ3PqN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 11:46:13 -0400
Received: by mail-pg0-f42.google.com with SMTP id v78so11950193pgb.5
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 08:46:13 -0700 (PDT)
In-Reply-To: <20171030151429.mdcvyxflhmrtvfah@ast-mbp.dhcp.thefacebook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2017 08:14 AM, Alexei Starovoitov wrote:
> On Mon, Oct 30, 2017 at 09:15:51PM +0900, David Miller wrote:
>>
>> BPF and tc action bug fixes in 'net' caused some extremely
>> painful merges with 'net-next'.
>>
>> Could the interested parties please take a look at 'net-next'
>> and send me any necessary fixes, as I did the best that I
>> could.
> 
> bpf side is good. John, please double check as well.
> 

Code looks good and all my tests passing successfully.

Thanks,
John
