From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core/sock.c: add missing VSOCK string in
 af_family_*_key_strings
Date: Tue, 28 May 2013 23:59:30 -0700 (PDT)
Message-ID: <20130528.235930.817011402865677291.davem@davemloft.net>
References: <1369753364-10043-1-git-send-email-federico.vaga@gmail.com>
	<51A4F05C.90001@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: federico.vaga@gmail.com, nhorman@tuxdriver.com,
	edumazet@google.com, lizefan@huawei.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51A4F05C.90001@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 28 May 2013 21:58:52 +0400

> Hello.
> 
> On 28-05-2013 19:02, Federico Vaga wrote:
> 
>> The three arrays of strings: af_family_kay_strings,
> 
>    s/kay/key/. Maybe whoever applies this could fix the typo...

Applied with typo fixed and queued up for -stable.

Thanks.
