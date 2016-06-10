From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH V2 00/11] net: mediatek: various small fixes
Date: Fri, 10 Jun 2016 19:50:33 +0200
Message-ID: <a333787c-ce3a-049e-8144-d07d38b55cfc@phrozen.org>
References: <1465558088-15265-1-git-send-email-john@phrozen.org>
 <ac8eae20-f8a5-6e06-43fd-c2826599b709@phrozen.org>
 <20160610.104604.309213239246401664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nbd@nbd.name,
	linux-mediatek@lists.infradead.org, keyhaede@gmail.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:40084 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753339AbcFJRum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 13:50:42 -0400
In-Reply-To: <20160610.104604.309213239246401664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/06/2016 19:46, David Miller wrote:
> From: John Crispin <john@phrozen.org>
> Date: Fri, 10 Jun 2016 13:30:15 +0200
> 
>>
>>
>> On 10/06/2016 13:27, John Crispin wrote:
>>> This series contains various small fixes that we stumbled across while
>>> doing thorough testing and code level reviewing of the driver. The only
>>> patch that sticks out is the first one, which addresses a DQL related
>>> issue. The rest are just minor fixes.
>>>
>>
>> Hi David,
>>
>> i forgot to remove the last sentence here. can you live with that as it
>> wont end up in the git history or do you want me to send a V3 with this
>> line removed.
> 
> What do you mean it won't end up in the GIT history?  I always put this
> introductory text into the merge commit for the patch series.
> 
> Now, I can remove it for you, which I will do.
> 

cool, thanks a lot !

	John
