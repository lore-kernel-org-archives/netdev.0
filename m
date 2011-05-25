From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH 17/34] hdlcdrv: Drop __TIME__ usage
Date: Wed, 25 May 2011 17:24:36 +0200
Message-ID: <4DDD1F34.7030702@suse.cz>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>	 <1302015561-21047-18-git-send-email-mmarek@suse.cz> <1302015790.4124.54.camel@xbox360.hq.axsem.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild <linux-kbuild@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>, linux-hams@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Thomas Sailer <t.sailer@alumni.ethz.ch>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1302015790.4124.54.camel@xbox360.hq.axsem.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5.4.2011 17:03, Thomas Sailer wrote:
> On Tue, 2011-04-05 at 16:59 +0200, Michal Marek wrote:
>> The kernel already prints its build timestamp during boot, no need to
>> repeat it in random drivers and produce different object files each
>> time.
>>
>> Cc: Thomas Sailer<t.sailer@alumni.ethz.ch>
>> Cc: linux-hams@vger.kernel.org
>> Cc: netdev@vger.kernel.org
>> Signed-off-by: Michal Marek<mmarek@suse.cz>
> Acked-By: Thomas Sailer<t.sailer@alumni.ethz.ch>
>
> Ok with me

I didn't find the commit in today's linux-next, so I applied this to
kbuild-2.6.git#trivial.

Michal
