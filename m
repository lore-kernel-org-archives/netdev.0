From: Daniele Venzano <venza@brownhat.org>
Subject: Re: [PATCH] sis900 Foxconn 661FX7MI-S PHY support
Date: Wed, 10 May 2006 22:17:59 +0200
Message-ID: <DE3A9CEF-A9D8-4FFA-A8D4-E8FFEE59834D@brownhat.org>
References: <20060510000450.GA5448@hp.com> <20060510103109.148197cd@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v749.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Cameron <james.cameron@hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.infomaniak.ch ([84.16.68.89]:1744 "EHLO
	smtp1.infomaniak.ch") by vger.kernel.org with ESMTP id S932467AbWEJUSI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 16:18:08 -0400
In-Reply-To: <20060510103109.148197cd@localhost.localdomain>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Il giorno 10/mag/06, alle ore 19:31, Stephen Hemminger ha scritto:

> On Wed, 10 May 2006 10:04:50 +1000 James Cameron  
> <james.cameron@hp.com> wrote:
>>
>> I'm not sure, but I wonder if it means the default behaviour  
>> should be
>> changed, so as to better handle future transceivers.
Well, my previous experience showed that the current default was the  
best, but obviously, when I decided that, things began to change.  
Since it is quite easy to add new transceivers this is hardly a big  
problem.

> I am waiting for a fixed patch and ack from driver maintainer.
Ack. :-)

Thanks.
--
Daniele Venzano
http://www.brownhat.org

