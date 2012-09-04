From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [PATCH 0/8] csiostor: Chelsio FCoE offload driver submission
Date: Tue, 4 Sep 2012 10:43:24 +0530
Message-ID: <50458DF4.1030907@chelsio.com>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com> <20120824.130406.1059160453285824849.davem@davemloft.net> <5037D043.7000302@chelsio.com> <20120824.151008.248026066556198861.davem@davemloft.net> <503922C0.7000707@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <503922C0.7000707@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/26/2012 12:38 AM, Naresh Kumar Inna wrote:
> On 8/25/2012 12:40 AM, David Miller wrote:
>> From: Naresh Kumar Inna <naresh@chelsio.com>
>> Date: Sat, 25 Aug 2012 00:34:35 +0530
>>
>>> Thanks for reviewing. Is your comment with respect to any particular
>>> module parameter[s] in this driver or all of them?
>>
>> All of them.
>>
> 
> So are module parameters being obsoleted? You mentioned about using
> generic kernel facilities for tuning driver knobs. Could you please
> elaborate a bit more?
> 
> Thanks,
> Naresh.
> --

Hi Dave,

Removing all the module parameters from the driver would put us at a
disadvantage with respect to tuning the driver and hardware. I have not
not been able to find alternatives, considering every other driver uses
module parameters. Could you provide pointers to the generic kernel
facilities you mentioned in your last post?

Thanks,
Naresh.
