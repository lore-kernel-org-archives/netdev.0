From: Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [GIT PULL] xhci: Regression fix for 3.13.
Date: Mon, 16 Dec 2013 22:33:51 -0500
Message-ID: <52AFC61F.3090301@pobox.com>
References: <cover.1386017042.git.sarah.a.sharp@linux.intel.com> <20131202214205.GA26175@kroah.com> <52A166CB.4020508@pobox.com> <20131206152512.GA23212@kroah.com> <52A29FB5.2010108@pobox.com> <20131216212132.GB8946@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131216212132.GB8946@xanatos>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 13-12-16 04:21 PM, Sarah Sharp wrote:
> On Fri, Dec 06, 2013 at 11:10:29PM -0500, Mark Lord wrote:
>> On 13-12-06 10:25 AM, Greg Kroah-Hartman wrote:
>>> On Fri, Dec 06, 2013 at 12:55:23AM -0500, Mark Lord wrote:
>>>> On 13-12-02 04:42 PM, Greg Kroah-Hartman wrote:
>>>>> On Mon, Dec 02, 2013 at 12:49:08PM -0800, Sarah Sharp wrote:
>>>>>> The following changes since commit c24cb6c8b501ebdf1aacec7960110a9741a45ced:
>>>>>>
>>>>>>   Merge tag 'fixes-for-v3.13-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb into usb-linus (2013-11-27 09:49:03 -0800)
>>>>>>
>>>>>> are available in the git repository at:
>>>>>>
>>>>>>   git://git.kernel.org/pub/scm/linux/kernel/git/sarah/xhci.git tags/for-usb-linus-2013-12-02
>>>>>
>>>>> Pulled and pushed out, thanks.
>>>>
>>>> Did this commit make it into linux-3.12.3 ?
>>>
>>> No, it's not there yet, as it's not in Linus's tree yet, give me a chance...
>>
>> Okay, good to see it moving along.
>>
>> I asked about 3.12.3, because something new in that release broke
>> Davids workaround for me here.
>>
>> But I'm with the rest of you: let's let what's in the pipeline
>> make it out there (3.12.4 ?) and then I'll retest and repatch that
>> if necessary to make things work here again.
> 
> Hi Mark,
> 
> 3.13-rc4 is out now, and it includes David's work-around.  Can you
> please test with that kernel and confirm it fixes your issues with the
> USB ethernet adapter?

Just giving it a whirl here tonight.  Looks good, thanks.
I won't have any further opportunity to thrash it until the New Year.

Thanks all!
-- 
Mark Lord
Real-Time Remedies Inc.
mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
