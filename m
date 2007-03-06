From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [RFC] div64_64 support
Date: Tue, 06 Mar 2007 10:50:19 -0800
Message-ID: <45EDB7EB.6090500@zytor.com>
References: <20070223170527.4ca695b2@freekitty> <20070305155714.3abe1b5e@freekitty> <20070306133404.GA864@one.firstfloor.org> <200703061519.20346.dada1@cosmosbay.com> <20070306144529.GA2004@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:59822 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030297AbXCFSv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 13:51:28 -0500
In-Reply-To: <20070306144529.GA2004@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>> <rant>
>> Let me see... You throw code like that and expect someone to actually 
>> understand it in one year, and be able to correct a bug ?
> 
> To be honest I don't expect any bugs in this function.
> 
>> </rant>
>>
>> Please add something, an URL or even better a nice explanation, per favor...
> 
> It's straight out of Hacker's delight which is referenced in the commit
> log.

Referencing it in a comment would have been a better idea.

	-hpa
