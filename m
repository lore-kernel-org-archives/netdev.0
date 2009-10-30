From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] RDS: minor updates for net-next
Date: Fri, 30 Oct 2009 15:06:57 -0700 (PDT)
Message-ID: <20091030.150657.173406625.davem@davemloft.net>
References: <1256928893-17844-1-git-send-email-andy.grover@oracle.com>
	<20091030.122326.73781593.davem@davemloft.net>
	<c0a09e5c0910301423k7726909frde1ae63e6ac9f009@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com
To: andy.grover@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50792
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757433AbZJ3WGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 18:06:33 -0400
In-Reply-To: <c0a09e5c0910301423k7726909frde1ae63e6ac9f009@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Grover <andy.grover@gmail.com>
Date: Fri, 30 Oct 2009 14:23:13 -0700

> On Fri, Oct 30, 2009 at 12:23 PM, David Miller <davem@davemloft.net> wrote:
>>> These patches fix some small issues with RDS, please review and
>>> apply if ok.
>> Adding new socket options is not appropriate for -rc* series
>> submissions.
>>
>> The changes that fix races and panics are fine, the rest is not.
>>
>> Please respin your changes properly for net-2.6, and we can add the
>> socket option and do the other stuff in net-next-2.6
> 
> I'm fine with it all going into net-next, actually. Even the fixes are
> not for showstopper bugs, and RDS is not a widely-used protocol.

Okie dokie, I've tossed all 5 patches into net-next-2.6

Thanks!
