From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] ath9k_htc: wmi: match wait_for_completion_timeout return type
Date: Thu, 21 May 2015 16:59:09 +0300
Message-ID: <87fv6q6ngy.fsf@kamboji.qca.qualcomm.com>
References: <1431621821-8173-1-git-send-email-hofrat@osadl.org>
	<87fv6zccny.fsf@kamboji.qca.qualcomm.com>
	<20150514174025.GA22524@opentech.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicholas Mc Guire <hofrat@osadl.org>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@venema.h4ckr.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Mc Guire <der.herr@hofr.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150514174025.GA22524@opentech.at> (Nicholas Mc Guire's message
	of "Thu, 14 May 2015 19:40:25 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicholas Mc Guire <der.herr@hofr.at> writes:

> On Thu, 14 May 2015, Kalle Valo wrote:
>
>> Nicholas Mc Guire <hofrat@osadl.org> writes:
>> 
>> > Patch is against 4.1-rc3 (localversion-next is -next-20150514)
>> 
>> BTW, this info should be under "---" line so that it doesn't get stored
>> to the actual commit log.
>>
> that is where I had been putting it until ask by Josh Triplett and 
> Steven Rostedt to put it above the "---" line explicitly
> see: http://lkml.org/lkml/2015/5/11/552 
>
> So now I'm a bit lost where to actually put this buildtest info ?

Different maintainers have different opinions, there is no one answer,
but if Steven is okay to have this in the commit log so am I. So no need
to change anything.

-- 
Kalle Valo
