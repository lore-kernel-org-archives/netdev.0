From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH RFC] pkt_sched: enable QFQ to support TSO/GSO
Date: Mon, 29 Oct 2012 19:31:03 +0800
Message-ID: <508E68F7.5080402@gmail.com>
References: <20121029085106.GA3733@paolo-ThinkPad-W520> <508E63AD.20803@gmail.com> <508E6783.2080403@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, davem@davemloft.net, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com
To: Paolo Valente <paolo.valente@unimore.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <508E6783.2080403@unimore.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/2012 07:24 PM, Paolo Valente wrote:
> Il 29/10/2012 12:08, Cong Wang ha scritto:
>>
>> Please respect people who helps you to test it:
>>
>> Tested-by: Cong Wang <amwang@redhat.com>
> Oops, really sorry about that. I did not mean to hide your contribution.
> I am just not familiar with the process.

No problem. :)


> Thanks, I will integrate this and possible other suggestions in a new
> version of the patch.

While you are on it, please check your patch with 
./scripts/checkpatch.pl, it complains there are some trailing 
whitespaces in your patch. ;)
