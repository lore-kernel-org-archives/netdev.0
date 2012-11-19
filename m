From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Latest 3.6.6 are not compiling due tg3 network driver,
 =?UTF-8?Q?hwmon=5Fdevice=5Funregister?=
Date: Mon, 19 Nov 2012 08:59:37 +0200
Message-ID: <d7418ec9ab1ae59a0ce5a101c6ff55e1@visp.net.lb>
References: <8b566c4a9ee622737212dc17291ee238@visp.net.lb>
 <50A4606D.4020402@broadcom.com>
 <alpine.DEB.2.00.1211141929510.14414@chino.kir.corp.google.com>
 <50A464E4.1080105@broadcom.com>
 <alpine.DEB.2.00.1211181441470.5080@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nithin Nayak Sujir <nsujir@broadcom.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Michael Chan <mchan@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Rientjes <rientjes@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1211181441470.5080@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2012-11-19 00:42, David Rientjes wrote:
> On Wed, 14 Nov 2012, Nithin Nayak Sujir wrote:
>
>> On 11/14/2012 07:30 PM, David Rientjes wrote:
>> > On Wed, 14 Nov 2012, Nithin Nayak Sujir wrote:
>> >
>> > > This was fixed by
>> > >
>> > > commit de0a41484c47d783dd4d442914815076aa2caac2
>> > > Author: Paul Gortmaker <paul.gortmaker@windriver.com>
>> > > Date:   Mon Oct 1 11:43:49 2012 -0400
>> > >
>> > >      tg3: unconditionally select HWMON support when tg3 is 
>> enabled.
>> > >
>> > Would you mind submitting this for stable by following the 
>> procedure
>> > described in Documentation/stable_kernel_rules.txt?
>> >
>>
>> Will do. Thank you for bringing this to our attention.
>>
>
> Thanks for submitting the patch to stable, Greg has queued it for the
> kernels he maintains.  Denys, expect to see this fix in 3.6.8.
Thank you!

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
