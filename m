From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH -next] net/mlx4_en: fix error return code in mlx4_en_get_qp()
Date: Wed, 8 Jan 2014 11:40:59 +0200
Message-ID: <52CD1D2B.1080307@mellanox.com>
References: <CAPgLHd9HUbNsD-rKi3CSVc6gG7TAn54mDJT2WcVu4K9kJ9PuYg@mail.gmail.com> <20140107.154328.116165277036485786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <amirv@mellanox.com>,
	<yongjun_wei@trendmicro.com.cn>, <netdev@vger.kernel.org>
To: <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:39782 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754162AbaAHJlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 04:41:19 -0500
In-Reply-To: <20140107.154328.116165277036485786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2014 22:43, David Miller wrote:
> From: Wei Yongjun <weiyj.lk@gmail.com>
> Date: Tue, 7 Jan 2014 16:56:07 +0800
>
>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>>
>> Fix to return a negative error code from the error handling
>> case instead of 0.
>>
>> Fixes: 837052d0ccc5 ('net/mlx4_en: Add netdev support for TCP/IP offloads of vxlan tunneling')
>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> Looks good, applied, thanks.

Indeed, thanks for spotting and fixing.

Or.
