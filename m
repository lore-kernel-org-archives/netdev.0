From: "Pan, Miaoqing" <miaoqing@qti.qualcomm.com>
Subject: Re: ath9k gpio request
Date: Wed, 1 Jun 2016 06:54:01 +0000
Message-ID: <1464764036580.70506@qti.qualcomm.com>
References: <20160530132225.4d297678@canb.auug.org.au>
	<574C4851.9090201@gmail.com>
 <87fusy3cqx.fsf_-_@kamboji.qca.qualcomm.com>,<574D3EAA.3060102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	ath9k-devel <ath9k-devel@qualcomm.com>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ath9k-devel@lists.ath9k.org" <ath9k-devel@lists.ath9k.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Miaoqing Pan <miaoqing@codeaurora.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <574D3EAA.3060102@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

which chip ?  And what's the GPIO number ?

Thanks,
Miaoqing

________________________________________
From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Sent: Tuesday, May 31, 2016 3:35 PM
To: Kalle Valo
Cc: Stephen Rothwell; ath9k-devel; linux-next@vger.kernel.org; linux-kernel@vger.kernel.org; linux-wireless@vger.kernel.org; ath9k-devel@lists.ath9k.org; netdev@vger.kernel.org; Miaoqing Pan
Subject: Re: ath9k gpio request

On Tuesday 31 May 2016 01:01 PM, Kalle Valo wrote:
> (Changing subject to a more descriptive one, was "Re: linux-next: Tree
> for May 30")
>
> Sudip Mukherjee <sudipm.mukherjee@gmail.com> writes:
>
>> Hi All,
>> I have just built and booted with next-20160530 and my dmesg is full
>> of warnings from ath9k. Last kernel tested was v4.6 and there was no
>> problem with that.
>>

<snip>


> The traces look incomplete to me, is there anything more before the
> "Call Trace:" line? Full unedited logs are usually the best.

sure, its attached. those two warnings are recursively going on and
there is nothing else left in dmesg to see what started it.

Regards
Sudip
