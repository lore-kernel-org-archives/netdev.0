From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 PATCH v3 4/5] rtnetlink: Add VF config code to
 rtnetlink
Date: Thu, 25 Feb 2010 11:18:15 +0100
Message-ID: <4B864E67.6080302@trash.net>
References: <20100210114303.14483.71368.stgit@localhost.localdomain> <20100210114403.14483.11004.stgit@localhost.localdomain> <4B72A061.40905@trash.net> <EA929A9653AAE14F841771FB1DE5A1365FE3CBE343@rrsmsx501.amr.corp.intel.com> <4B853468.10509@trash.net> <EA929A9653AAE14F841771FB1DE5A1365FE42DE401@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63412 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758870Ab0BYKSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 05:18:17 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FE42DE401@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Williams, Mitch A wrote:
>> -----Original Message-----
>> From: Patrick McHardy [mailto:kaber@trash.net]
> 
> [snip]
> 
>> I just noticed the patch went in without any of these changes.
>> Are you going to fix this up?
> 
> I've got a patch in Jeff's queue that takes care of the low-hanging
> fruit - return codes and excessive locking. You should see this go
> up pretty quickly.
>  
> I'm planning to look into the data structure changes today. 

Thanks for the information.
