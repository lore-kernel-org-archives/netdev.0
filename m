From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] Bug fixes in ena ethernet driver
Date: Sat, 10 Jun 2017 16:11:33 -0400 (EDT)
Message-ID: <20170610.161133.722413665016881379.davem@davemloft.net>
References: <1497046437-20390-1-git-send-email-netanel@amazon.com>
        <fac900d3-dae3-1c88-ceef-d28294ed7941@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netanel@amazon.com, netdev@vger.kernel.org, dwmw@amazon.com,
        zorik@amazon.com, matua@amazon.com, saeedb@amazon.com,
        msw@amazon.com, aliguori@amazon.com, nafea@amazon.com,
        evgenys@amazon.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751563AbdFJULg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 16:11:36 -0400
In-Reply-To: <fac900d3-dae3-1c88-ceef-d28294ed7941@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 9 Jun 2017 15:19:54 -0700

> On 06/09/2017 03:13 PM, netanel@amazon.com wrote:
>> From: Netanel Belgazal <netanel@amazon.com>
>> 
>> This patchset contains fixes for the bugs that were discovered so far.
> 
> If these are all fixes you should submit them against the "net" tree.
> net-next is for features [1].
> 
> Since these are fixes, you may also want to provide a Fixes: 12-digit
> commit ("commit subject") [2] such that David can queue these patches
> for stable trees and this can be retrofitted into kernel distributions.
> 
> [1]:
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/netdev-FAQ.txt#n25
> 
> [2]:
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/process/submitting-patches.rst#n183

Yeah I agree.  If they are genuine bug fixes they should be submitted
against 'net'.  And yes, Fixes: tags are quite desirable as well.
