From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 00/11] net: mediatek: various small fixes
Date: Fri, 10 Jun 2016 10:46:04 -0700 (PDT)
Message-ID: <20160610.104604.309213239246401664.davem@davemloft.net>
References: <1465558088-15265-1-git-send-email-john@phrozen.org>
	<ac8eae20-f8a5-6e06-43fd-c2826599b709@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: keyhaede@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
	nbd@nbd.name
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ac8eae20-f8a5-6e06-43fd-c2826599b709@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Fri, 10 Jun 2016 13:30:15 +0200

> 
> 
> On 10/06/2016 13:27, John Crispin wrote:
>> This series contains various small fixes that we stumbled across while
>> doing thorough testing and code level reviewing of the driver. The only
>> patch that sticks out is the first one, which addresses a DQL related
>> issue. The rest are just minor fixes.
>> 
> 
> Hi David,
> 
> i forgot to remove the last sentence here. can you live with that as it
> wont end up in the git history or do you want me to send a V3 with this
> line removed.

What do you mean it won't end up in the GIT history?  I always put this
introductory text into the merge commit for the patch series.

Now, I can remove it for you, which I will do.
