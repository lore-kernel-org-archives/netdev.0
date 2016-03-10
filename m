From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/2] sh_eth: fix couple of bugs in sh_eth_ring_format()
Date: Fri, 11 Mar 2016 01:01:22 +0300
Message-ID: <56E1EEB2.60106@cogentembedded.com>
References: <4881302.XJJSmqvE1J@wasted.cogentembedded.com>
 <20160310.160752.440578142471376021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160310.160752.440578142471376021.davem@davemloft.net>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/11/2016 12:07 AM, David Miller wrote:

>>     Here's a set of 2 patches against DaveM's 'net.git' repo fixing two bugs
>> in sh_eth_.ring_format()...
>>
>> [1/2] sh_eth: fix NULL pointer dereference in sh_eth_ring_format()
>> [2/2] sh_eth: advance 'rxdesc' later in sh_eth_ring_format()
>
> Since Linus is likely to release today or otherwise very soon I'm not
> putting things into 'net'.
>
> So I've applied this series to 'net-next', let me know if I should
> queue it up for stable.

    If your generally queue the error path fixes, then queue these two please.

> Thanks.

    My pleasure. :-)

MBR, Sergei
