From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH][next][V2] bpf: test_maps: fix typo "conenct" -> "connect"
Date: Wed, 30 Aug 2017 18:09:37 +0100
Message-ID: <c973fcee-2d02-7ece-fa8f-604b5ed8c92d@canonical.com>
References: <20170830114730.28550-1-colin.king@canonical.com>
 <59A6C1B9.3050005@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Shuah Khan <shuah@kernel.org>, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:60663 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752053AbdH3RJj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 13:09:39 -0400
In-Reply-To: <59A6C1B9.3050005@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/08/17 14:46, Daniel Borkmann wrote:
> On 08/30/2017 01:47 PM, Colin King wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> Trivial fix to typo in printf error message
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> 
> For net-next; looks like there is also one in "failed to listeen\n".
> Want to fix this one as well ? ;)

Ah, missed that one. Thanks.
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
