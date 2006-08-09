From: Mohamed Abbas <mabbas@linux.intel.com>
Subject: Re: d80211 merge plans
Date: Wed, 09 Aug 2006 13:09:11 -0700
Message-ID: <44DA40E7.3040806@linux.intel.com>
References: <200608090703.45651.mb@bu3sch.de> <20060808.224838.41637123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, jbenc@suse.cz, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:57015 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S1751343AbWHIUJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 16:09:19 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060808.224838.41637123.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

>From: Michael Buesch <mb@bu3sch.de>
>Date: Wed, 9 Aug 2006 07:03:41 +0200
>
>  
>
>>I am wondering about d80211 mainline merge plans.
>>    
>>
>
>I think this is a non-started until the SMP problems are worked
>out.  Is it still SMP challenged?
>-
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>  
>
I been using d80211 stack for about a month I have not encounter any SMP 
issues. We are currently involving validation engineers to do more 
stress tests and will see if any SMP issues come up.
Mohamed
