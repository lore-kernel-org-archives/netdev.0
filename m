From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH v3 00/14] RDS: connection scalability and performance
 improvements
Date: Wed, 7 Oct 2015 08:58:32 -0700
Message-ID: <56154128.2010309@oracle.com>
References: <1444067797-14101-1-git-send-email-santosh.shilimkar@oracle.com>
 <20151007.021634.1127057852275250731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151007.021634.1127057852275250731.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/7/15 2:16 AM, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Date: Mon,  5 Oct 2015 10:56:23 -0700
>
>> [v3]
>> Updated patch "[PATCH v2 05/14] RDS: defer the over_batch work to
>> send worker" as per David Miller's comment [4] to avoid the magic
>> value usage. Patch now makes use of already available but unused
>> send_batch_count module parameter. Rest of the patches are same as
>> earlier version v2 [3]
>
> Can you respin this again?  Your repost of patch 05/14 was severely whitespace
> damaged.
>
Sorry about that. I thought mailer won't eat tabs but it did. Just sent
the series again. Bumped up the version to v4 from archives perspective.

Thanks !!

Regards,
Santosh
