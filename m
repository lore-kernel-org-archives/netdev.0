From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: [PATCH] 2.6.24-mm1 section type conflict cleanup
Date: Tue, 05 Feb 2008 10:19:10 +0530
Message-ID: <47A7EAC6.8020201@linux.vnet.ibm.com>
References: <20080203171634.58ab668b.akpm@linux-foundation.org> <20080204162223.GA6888@linux.vnet.ibm.com> <20080204180454.GA16050@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	apw@shadowen.org, balbir@linux.vnet.ibm.com
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP01.au.ibm.com ([202.81.18.162]:41370 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752888AbYBEEtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 23:49:16 -0500
In-Reply-To: <20080204180454.GA16050@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sam Ravnborg wrote:
> On Mon, Feb 04, 2008 at 09:52:23PM +0530, Kamalesh Babulal wrote:
>> Hi Andrew,
>>
>> The 2.6.24-mm1 kernel build fails at many places with section type
>> conflict build error.
> 
> What arch?
> We have troubles with powerpc as pointed out by Al in another thread.
> 
> 	Sam
Hi Sam,

This clean up is done for the powerpc, sorry forgot to mention it.

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
