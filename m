From: Andrew Bennieston <andrew.bennieston@citrix.com>
Subject: Re: [PATCH V7 net-next 7/7] xen-net{back,front}: Document multi-queue
 feature in netif.h
Date: Wed, 30 Apr 2014 17:47:48 +0100
Message-ID: <53612934.9090504@citrix.com>
References: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com> <1398778035-26233-8-git-send-email-andrew.bennieston@citrix.com> <20140430145109.GD19082@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>,
	<ian.campbell@citrix.com>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <david.vrabel@citrix.com>,
	<zoltan.kiss@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:8407 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422664AbaD3Qru (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2014 12:47:50 -0400
In-Reply-To: <20140430145109.GD19082@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/04/14 15:51, Wei Liu wrote:
> On Tue, Apr 29, 2014 at 02:27:15PM +0100, Andrew J. Bennieston wrote:
>> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
>>
>> Document the multi-queue feature in terms of XenStore keys to be written
>> by the backend and by the frontend.
>>
>> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
>
> I presume you will use V3 posted on xen-devel.
>
> Wei.
>
Indeed. I didn't want to have to immediately post a V8 of this, 
containing only the header doc. changes, but the intention is to use 
exactly the same text as the patch submitted to xen-devel.

Andrew
