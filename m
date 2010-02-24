From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v5 2/3] sysctl: add proc_do_large_bitmap
Date: Wed, 24 Feb 2010 13:34:16 +0800
Message-ID: <4B84BA58.3040701@redhat.com>
References: <1266752533.3428.28.camel@Nokia-N900-42-11> <4B81EFD8.8020202@redhat.com> <201002221829.13987.opurdila@ixiacom.com> <4B84B7F0.7090709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B84B7F0.7090709@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cong Wang wrote:
>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>> index 5259727..d8ea839 100644
>> --- a/kernel/sysctl.c
>> +++ b/kernel/sysctl.c
>> @@ -2635,6 +2635,140 @@ static int proc_do_cad_pid(struct ctl_table 
>> *table, int write,
> 
> 
> The above line is wrong, it should be a part of previous line.
> 
> 

Sorry, ignore this, it should be my thunderbird's fault,
it truncated the line. I will fix it...
