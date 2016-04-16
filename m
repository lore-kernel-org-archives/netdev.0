From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [net][PATCH v2 0/2] RDS: couple of fixes for 4.6
Date: Sat, 16 Apr 2016 16:57:37 -0700
Message-ID: <5712D171.70907@oracle.com>
References: <1460655807-26236-1-git-send-email-santosh.shilimkar@oracle.com>
 <20160416.185342.1833113899705435419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160416.185342.1833113899705435419.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/16/2016 3:53 PM, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Date: Thu, 14 Apr 2016 10:43:25 -0700
>
>>    git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux.git for_4.6/net/rds-fixes
>
> I have no idea how you set this up, but there is no WAY this can be
> pulled from by me.
>
Thought I did based it against 'net' after your last comment.
Just checked again and the 'net' remote added by me points
to wrong url(net-next).

> When I try to pull it into 'net' I get 2690 objects.  That means you
> didn't base it upon the 'net' tree which you must do.  You can't base
> it upon Linus's tree, because if you do I'll get a ton of changes that
> are absolutely not appropriate to be pulled into my 'net' tree.
>
> Are you always doing this?  Working against Linus's tree instead of
> mine?
>
No, its not Linus's tree. Its yours but not the right one.
Sorry for the trouble. Won't happen again.

Thanks for picking up the matches from patchworks.

Regards,
Santosh
