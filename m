From: David VomLehn <vomlehn@texas.net>
Subject: Re: [PATCH v5 01/13] net: ethernet: aquantia: Make and configuration
 files.
Date: Thu, 12 Jan 2017 21:24:08 -0800
Message-ID: <a1dcfa57-97a1-dc20-6d8d-60cba3be3a56@texas.net>
References: <cover.1484283610.git.vomlehn@texas.net>
 <fe1664e502d28bcb6a5689787b8000e6c9288307.1484283610.git.vomlehn@texas.net>
 <1484283977.3065.24.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Joe Perches <joe@perches.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda4.aus1.datafoundry.com ([209.99.124.135]:54775 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750775AbdAMFoB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 00:44:01 -0500
In-Reply-To: <1484283977.3065.24.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 09:06 PM, Joe Perches wrote:
> On Thu, 2017-01-12 at 21:02 -0800, Alexander Loktionov wrote:
>> From: David VomLehn <vomlehn@texas.net>
>>
>> Patches to create the make and configuration files.
> This patch should _really_ be the last in the series
> not the first.
>
Could you explain the basis for this? By convention, we put tables of 
content at the beginning of books and only indices at the back. 
Analogously, make and config files can be used to established the 
context for what follows, making it easier to understand. Once 
committed, of course, the order no longer matters except as bisection is 
concerned.

-- 
David VL
