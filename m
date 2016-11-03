From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next v1 00/21] amd-xgbe: AMD XGBE driver updates
 2016-11-01
Date: Thu, 3 Nov 2016 12:23:40 -0500
Message-ID: <e85de010-c2a6-98cb-609a-bcf570a694e1@amd.com>
References: <20161103132744.3437.27332.stgit@tlendack-t1.amdoffice.net>
 <20161103.131405.2110100650645460415.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0071.outbound.protection.outlook.com ([104.47.34.71]:51993
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1758960AbcKCRXy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 13:23:54 -0400
In-Reply-To: <20161103.131405.2110100650645460415.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2016 12:14 PM, David Miller wrote:
> 
> 20+ patches is too many to submit at one time.
> 
> Making huge patch series submissions puts an unreasonable burdon on
> those developers who might decide to review your work, including me.
> 
> Please keep your series down to a small, reasonable, size.  Perhaps
> 10-15 patches maximum.

Ok, I'll break this up into smaller submissions - new device prep
work and then the new device support.

Thanks,
Tom

> 
> I will not be looking at nor applying this series.
> 
