From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 4/5] netlink: pass extended ACK struct to
 parsing functions
Date: Wed, 12 Apr 2017 16:08:23 +0200
Message-ID: <20170412140823.GJ1952@nanopsycho>
References: <20170412123408.22012-1-johannes@sipsolutions.net>
 <20170412123408.22012-5-johannes@sipsolutions.net>
 <20170412131708.GC1952@nanopsycho>
 <8737ddd8r0.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Johannes Berg <johannes.berg@intel.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35167 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751123AbdDLOIZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 10:08:25 -0400
Received: by mail-wm0-f65.google.com with SMTP id d79so6675910wmi.2
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 07:08:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <8737ddd8r0.fsf@purkki.adurom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 12, 2017 at 04:02:27PM CEST, kvalo@codeaurora.org wrote:
>Jiri Pirko <jiri@resnulli.us> writes:
>
>> Wed, Apr 12, 2017 at 02:34:07PM CEST, johannes@sipsolutions.net wrote:
>>>From: Johannes Berg <johannes.berg@intel.com>
>>>
>>>Pass the new extended ACK reporting struct to all of the
>>
>> Johannes, I wonder, is there a reason you ignore my comments about
>> narrow descriptions? Why don't you use the whole line?
>
>Seriously, you ask that with totally unnecessary 3800 lines of quotes?
>
>(Or at least I assume so, I didn't bother to check if you had any
>comments there as it would have taken forever to find them.)

Yep, that I did not remove. Sorry about that. Will behave the next time.
