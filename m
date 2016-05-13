From: Andy Gross <andy.gross@linaro.org>
Subject: Re: QRTR merge conflict resolution (was: Re: linux-next: build
 failure after merge of the net-next tree)
Date: Fri, 13 May 2016 17:47:17 -0500
Message-ID: <CAPBZ5Qfa+b1LLgqpxfKGysY5jXVrzmBzhga=ZYtpdDAKC9hnTQ@mail.gmail.com>
References: <20160510112905.5bffcad8@canb.auug.org.au>
	<20160510183934.GJ1256@tuxbot>
	<2606282.lG9qK7uBW0@wuerfel>
	<20160513221909.GC1256@tuxbot>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev@vger.kernel.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	linux-next@vger.kernel.org, Olof Johansson <olof@lixom.net>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160513221909.GC1256@tuxbot>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13 May 2016 at 17:19, Bjorn Andersson <bjorn.andersson@linaro.org> wrote:
> On Fri 13 May 14:01 PDT 2016, Arnd Bergmann wrote:
>
>> On Tuesday 10 May 2016 11:39:34 Bjorn Andersson wrote:
> [..]
>> > I assume we could have the QRTR go through Andy and arm-soc, with
>> > David's approval and this fix squashed in. But we're running rather late
>> > in this cycle, perhaps we should just back the QRTR patches out and I
>> > can respin and resend them after the merge window (for v4.8 instead)?
>>
>> I'd suggest you do a merge of next-next with the qcom/soc-2 branch that
>> we have in arm-soc and resolve the conflict in the merge, then send
>> a pull request with the merge to davem.
>>
>
> Hi David,
>
> In case you missed this thread, linux-next highlighted an upcoming merge
> conflict between the net-next and one of the branches included in the
> arm-soc trees.
>
> I have prepared the merge of net-next and the conflicting tag from the
> Qualcomm SOC, please include this in your pull towards Linus to avoid
> the merge conflict.
>
> Regards,
> Bjorn
>
> The following changes since commit ed7cbbce544856b20e5811de373cf92e92499771:
>
>   udp: Resolve NULL pointer dereference over flow-based vxlan device (2016-05-13 01:56:14 -0400)


OK. The contents look good to me.

Acked-by: Andy Gross <andy.gross@linaro.org>
