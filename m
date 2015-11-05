From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] pptp: use idr for allocation of callids
Date: Thu, 5 Nov 2015 15:17:11 -0500
Message-ID: <563BB947.1080008@oracle.com>
References: <1446754064-1195-1-git-send-email-sasha.levin@oracle.com>
 <20151105.151248.1982764713298691007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151105.151248.1982764713298691007.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/05/2015 03:12 PM, David Miller wrote:
> From: Sasha Levin <sasha.levin@oracle.com>
> Date: Thu,  5 Nov 2015 15:07:44 -0500
> 
>> > The current implementation used a bitfield with a corresponding array to
>> > manage assignment of call ids. Rather than open-coding it, use IDR for
>> > this.
>> > 
>> > Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> Please resubmit this when the net-next tree opens back up, thanks.

Will do, sorry.


Thanks,
Sasha
