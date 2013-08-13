From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH V2 0/4] Enable bus master till the FLR completes for Chelsio
 T4
Date: Tue, 13 Aug 2013 14:53:35 -0700
Message-ID: <520AAADF.7080801@chelsio.com>
References: <1375784319-25760-1-git-send-email-vipul@chelsio.com> <CAErSpo7=oBG3tJBpwscnL-4D-9kLhHUrQSZFrRRC4sBsT2_U2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vipul Pandya <vipul@chelsio.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	tomreu@chelsio.com, divy@chelsio.com, dm@chelsio.com,
	nirranjan@chelsio.com, eilong@broadcom.com,
	netdev <netdev@vger.kernel.org>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:36319
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758226Ab3HMVyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 17:54:11 -0400
In-Reply-To: <CAErSpo7=oBG3tJBpwscnL-4D-9kLhHUrQSZFrRRC4sBsT2_U2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 08/12/13 14:17, Bjorn Helgaas wrote:
> On Tue, Aug 6, 2013 at 4:18 AM, Vipul Pandya <vipul@chelsio.com> wrote:
>> This patch series adds device specific reset method for Chelsio T4 adapters.
>>
>> ...
> Applied to my "next" branch for v3.12, thanks!
>

   Thanks Bjorn!  Do you have an idea when these commits will hit Linus' 
repository and what their git commit IDs will be?  We have a customer 
using SLES11sp2 who needs this and once the commits hit Linus' 
repository we'll need to send a request to Novell to pull the change 
sets into SLES11sp2.  Thanks!

Casey
