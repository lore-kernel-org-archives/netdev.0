From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: sh_eth: avoid NULL pointer dereference in ring setup
Date: Wed, 2 Mar 2016 20:47:34 +0300
Message-ID: <56D72736.1090502@cogentembedded.com>
References: <1456932370-4143-1-git-send-email-wsa@the-dreams.de>
 <56D71909.2020503@cogentembedded.com> <20160302171114.GB5439@katana>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	linux-renesas-soc@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160302171114.GB5439@katana>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/02/2016 08:11 PM, Wolfram Sang wrote:

>>> Reported-by: coverity (CID 1056464)
>>> Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>
>>
>>     Will you respin or should I?
>
> Please go ahead. You have more knowledge about this driver, so you will
> be faster.

    Not necessarily -- I have other bug to chase right now. :-)

> Reported-by: Wolfram Sang <wsa+renesas@sang-engineering.com>

    Thanks for reporting, anyway.

MBR, Sergei
