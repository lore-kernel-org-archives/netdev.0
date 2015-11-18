From: Jason Gerard DeRose <jason@system76.com>
Subject: Re: [PATCH] ethernet/atheros/alx: add Killer E2400 device ID
Date: Wed, 18 Nov 2015 11:15:45 -0700
Message-ID: <564CC051.7030805@system76.com>
References: <1447809667-9454-1-git-send-email-jason@system76.com>
 <564C84BF.1090202@cogentembedded.com> <564C90BB.2040104@system76.com>
 <564CB9C4.3030100@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Pope <benpope81@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.system76.com ([38.75.196.72]:40435 "EHLO mail.system76.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755244AbbKRSPr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 13:15:47 -0500
In-Reply-To: <564CB9C4.3030100@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/18/2015 10:47 AM, Sergei Shtylyov wrote:
> On 11/18/2015 05:52 PM, Jason Gerard DeRose wrote:
>
>>>> From: Ben Pope <benpope81@gmail.com>
>>>>
>>>> This patch adds the PCI device ID (0xe0a1) and alx_pci_tbl entry for
>>>> the
>>>> Killer E2400 Ethernet controller, modeled after the Killer E2200
>>>> controller support (0xe091) already present in the alx driver.
>>>>
>>>> This patch was originally authored by Ben Pope, but it got held up by
>>>> issues in the commit message, so I'm resubmitting it on his behalf.
>>>>
>>>> I've extensively used a kernel with this patch on a System76 serw9
>>>> laptop and am quite confident it works well (at least on the hardware I
>>>> have available for testing).
>>>>
>>>> Note that as a favor to System76, Ubuntu has been carrying this as a
>>>> sauce patch in their 4.2 based Wily kernel, which presumably has given
>>>> it real-world testing on other E2400 equipped hardware (I don't know of
>>>> any Ubuntu kernel bugs filed about it):
>>>>
>>>> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1498633
>>>>
>>>> Signed-off-by: Jason Gerard DeRose <jason@system76.com>
>>>
>>>     No sign-off from Ben?
>>
>> Apologies, this is my first time submitting a kernel patch :)
>>
>> Should I use git send-email to send this again,
>
>     I didn't notice if your mailer corrupted the patch but if it did
> 'git send-email' should be used indeed.

I originally used `git send-email`, so the patch should not have been 
corrupted.

>> this time with the sign-off from Ben?
>
>     No need to resend if it wasn't corrupted. Just replying to this
> patch with his sign-off should be enough -- patchwork should collect the
> tags from the follow-ups.

Okay, thanks for the clarification!

>> And if so, should I do so as a reply to this thread?
>
>     No, not on this list. DaveM prefers the patch reposts to be done as
> the fresh new postings.
>
>> Thanks for you time!
>
>     Your, I guess? Not at all. :-)

Also thank you for enduring my typos ;)

> MBR, Sergei
>
