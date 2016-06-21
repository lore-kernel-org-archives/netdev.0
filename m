From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: vrf: replace hard tab with space in assignment
Date: Mon, 20 Jun 2016 21:49:45 -0600
Message-ID: <d1817037-2d4c-3c57-df2f-22262fdcb006@cumulusnetworks.com>
References: <20160621033943.21947-1-chris.packham@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, shm@cumulusnetworks.com
To: Chris Packham <chris.packham@alliedtelesis.co.nz>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160621033943.21947-1-chris.packham@alliedtelesis.co.nz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/20/16 9:39 PM, Chris Packham wrote:
> The assignment of rth->dst.output in vrf_rt6_create() and
> vrf_rtable_create() used a hard tab before the '='. The neighboring
> assignments did not. Make the assignment of rth->dst.output consistent
> with the surrounding code.
>
> Signed-off-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
> ---
>  drivers/net/vrf.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Acked-by: David Ahern <dsa@cumulusnetworks.com>
