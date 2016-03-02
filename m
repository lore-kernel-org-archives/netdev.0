From: John Holland <jotihojr@gmail.com>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211 using a device tree blob V5
Date: Wed, 2 Mar 2016 04:48:28 +0100
Message-ID: <63942260-AF46-475D-9963-8A7A10484906@gmail.com>
References: <56C5A6BC.6030708@gmail.com> <309B89C4C689E141A5FF6A0C5FB2118B81EA731A@ORSMSX101.amr.corp.intel.com> <DC20A3D2-95E2-420B-911D-C6AC02338227@gmail.com> <1456876509.3039.10.camel@intel.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Brown, Aaron F" <aaron.f.brown@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35736 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbcCBDsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 22:48:31 -0500
Received: by mail-wm0-f53.google.com with SMTP id l68so66075866wml.0
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 19:48:30 -0800 (PST)
In-Reply-To: <1456876509.3039.10.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 02.03.2016, at 00:55, Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
>> On Tue, 2016-03-01 at 07:56 +0100, John Holland wrote:
>> On Mar 1, 2016, at 03:52, Brown, Aaron F <aaron.f.brown@intel.com>
>> wrote:
>> 
>>> This throws a few checkpatch warnings, but I won't withhold my
>> tested by for these:
>>>  
>>> total: 0 errors, 2 warnings, 0 checks, 21 lines checked
>>>  
>>> Your patch has style problems, please review.
>>>  
>>> NOTE: If any of the errors are false positives, please report
>>>       them to the maintainer, see CHECKPATCH in MAINTAINERS.
>>> u1463:[0]/usr/src/kernels/next-queue>
>> 
>> Thanks for testing...
>> 
>> Do you require me to reformat the patch text? And won't that break
>> the link?
> 
> No, that checkpatch.pl warning on the link you provided is fine,
> although I will clean up your signed-off-by when I go to push it
> upstream. :-)

Thank you very much!
