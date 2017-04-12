From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH net-next v5 4/5] netlink: pass extended ACK struct to parsing functions
Date: Wed, 12 Apr 2017 17:02:27 +0300
Message-ID: <8737ddd8r0.fsf@purkki.adurom.net>
References: <20170412123408.22012-1-johannes@sipsolutions.net>
        <20170412123408.22012-5-johannes@sipsolutions.net>
        <20170412131708.GC1952@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Johannes Berg <johannes.berg@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33088 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753947AbdDLOCe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 10:02:34 -0400
In-Reply-To: <20170412131708.GC1952@nanopsycho> (Jiri Pirko's message of "Wed,
        12 Apr 2017 15:17:08 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:

> Wed, Apr 12, 2017 at 02:34:07PM CEST, johannes@sipsolutions.net wrote:
>>From: Johannes Berg <johannes.berg@intel.com>
>>
>>Pass the new extended ACK reporting struct to all of the
>
> Johannes, I wonder, is there a reason you ignore my comments about
> narrow descriptions? Why don't you use the whole line?

Seriously, you ask that with totally unnecessary 3800 lines of quotes?

(Or at least I assume so, I didn't bother to check if you had any
comments there as it would have taken forever to find them.)

-- 
Kalle Valo
