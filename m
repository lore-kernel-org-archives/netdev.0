From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [ANNOUNCE] iproute2 4.1.0
Date: Fri, 26 Jun 2015 15:35:04 -0700
Message-ID: <558DD398.7020003@cumulusnetworks.com>
References: <20150626130616.5a350099@urahara> <558DC8D7.4080803@cumulusnetworks.com> <20150626153349.2b0152c9@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34689 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbbFZWfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 18:35:06 -0400
Received: by pabvl15 with SMTP id vl15so75204361pab.1
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 15:35:06 -0700 (PDT)
In-Reply-To: <20150626153349.2b0152c9@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/26/15, 3:33 PM, Stephen Hemminger wrote:
> On Fri, 26 Jun 2015 14:49:11 -0700
> roopa <roopa@cumulusnetworks.com> wrote:
>
>> Hi Stephen,
>>
>> I don't see the below fix in the 4.1 tarball you point below:
>> https://patchwork.ozlabs.org/patch/479743/
>>
>> I am not sure yet if there was a problem with my submission. I intended
>> for it to go into 4.1.
>>
>> Thanks,
>> Roopa
> That is held off I thought mpls needed net-next (4.2) not 4.1.
> It is merged into master (post 4.1).
>
Mpls is in 4.1 and the route dels are broken without this fix.

Thanks,
Roopa
