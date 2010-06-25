From: Cong Wang <amwang@redhat.com>
Subject: Re: [v4 Patch 1/2] s2io: add dynamic LRO disable support
Date: Fri, 25 Jun 2010 17:01:36 +0800
Message-ID: <4C247070.9030003@redhat.com>
References: <20100622085415.5566.22523.sendpatchset@localhost.localdomain> <20100625043343.GB2739@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sgruszka@redhat.com" <sgruszka@redhat.com>,
	"herbert.xu@redhat.com" <herbert.xu@redhat.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jon Mason <jon.mason@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1051 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752113Ab0FYI5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jun 2010 04:57:34 -0400
In-Reply-To: <20100625043343.GB2739@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/10 12:33, Jon Mason wrote:
> On Tue, Jun 22, 2010 at 01:50:07AM -0700, Amerigo Wang wrote:
>>
>> This patch adds dynamic LRO diable support for s2io net driver.
>>
>> (I don't have s2io card, so only did compiling test. Anyone who wants
>> to test this is more than welcome.)
>
> Unfortunately the patch did not quite work, mostly due to NETIF_F_LRO
> needing to be added at probe time to the device features.  I was able
> to modify the patch to get it working, and will respond seperately
> with the working patch.
>

Thanks very much, Jon!

I am very pleased to see this patch gets tested. :)
