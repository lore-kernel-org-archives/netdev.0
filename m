From: kishan simha <ksimha123@gmail.com>
Subject: Re: Information about SCTP patch
Date: Mon, 21 Jul 2014 14:08:21 +0530
Message-ID: <CAJ5TDg_qOkpGe7Ouzn_wfbsODL4FoVLmq7EmQes6hEW-dnMLWg@mail.gmail.com>
References: <CAJ5TDg_0GjTWVin1Xr4sZwNhzMiT+bJPZwzfKB0xBdPMuK7T+g@mail.gmail.com>
	<20140627200644.GA9086@marquez.int.rhx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	prasad.padiyar@nsn.com, sumit.11.kumar@nsn.com
To: Michele Baldessari <michele@acksyn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:57787 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439AbaGUIiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 04:38:21 -0400
In-Reply-To: <20140627200644.GA9086@marquez.int.rhx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Michele,

Thank you for the response.

I have a few more queries regarding the patch.

We are trying to integrate this patch to a little older kernel 2.6.34.13.
Additionally we are planning to give a proc file interface to display the stats.

I came across a review comment for your patch, where the proc solution
was rejected.

Can you provide some information on why the solution was rejected ?

Thanks and Regards
Kishan



On Sat, Jun 28, 2014 at 1:36 AM, Michele Baldessari <michele@acksyn.org> wrote:
> Hi Kishan,
>
> On Thu, Jun 26, 2014 at 12:58:54PM +0530, kishan simha wrote:
>> I wanted some information on the SCTP patch   "sctp: Add support to
>> per-association statistics via a new SCTP_GET_ASSOC_STA "
>>
>> The commit information is
>> commit 196d67593439b03088913227093e374235596e33
>> Author: Michele Baldessari <michele@acksyn.org>
>> Date:   Sat Dec 1 04:49:42 2012 +0000
>>
>> Is it possible to know into which kernel version did this patch go into?
>> I tried to find it online and I was not able to. Hence mailing to this list.
>
> as Eric mentioned, it's in 3.8 (or also in RHEL-6.5). Feel free to reach out
> if you have any questions.
>
> cheers,
> Michele
> --
> Michele Baldessari            <michele@acksyn.org>
> C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
