From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT] netxen: fix CONFIG_INET=n build
Date: Wed, 29 Jul 2009 21:42:07 -0700 (PDT)
Message-ID: <20090729.214207.193697413.davem@davemloft.net>
References: <1248808203-9578-1-git-send-email-dhananjay@netxen.com>
	<20090728122352.6d4a2b05.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhananjay@netxen.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090728122352.6d4a2b05.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 28 Jul 2009 12:23:52 -0700

> On Tue, 28 Jul 2009 12:10:03 -0700 Dhananjay Phadke wrote:
> 
>> Wrap dest IP hashing code with #ifdef CONFIG_INET,
>> this feature makes no sense without INET, but other
>> driver can still work.
>> 
>> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> 
> Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks.
