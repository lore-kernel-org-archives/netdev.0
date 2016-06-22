From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next v4 0/5] bridge: json support for fdb and
 vlan show
Date: Wed, 22 Jun 2016 11:23:56 -0700
Message-ID: <CAJieiUgwHvPG7LMFwjEysDxbcWnGbMhkyWikW3Y4Ue51oFWfxQ@mail.gmail.com>
References: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
 <20160622145344.GE2068@nanopsycho.orion> <20160622111047.1523b06f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Anuradha Karuppiah <anuradhak@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Julien Fortin <julien@cumulusnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:36489 "EHLO
	mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbcFVSX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 14:23:58 -0400
Received: by mail-vk0-f49.google.com with SMTP id u64so73431792vkf.3
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 11:23:57 -0700 (PDT)
In-Reply-To: <20160622111047.1523b06f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 11:10 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 22 Jun 2016 16:53:44 +0200
> Jiri Pirko <jiri@resnulli.us> wrote:
>
>> Wed, Jun 22, 2016 at 03:45:50PM CEST, roopa@cumulusnetworks.com wrote:
>> >From: Roopa Prabhu <roopa@cumulusnetworks.com>
>> >
>> >This patch series adds json support for a few bridge show commands.
>> >We plan to follow up with json support for additional commands soon.
>>
>> I'm just curious, what is you use case for this? Apps can use rtnetlink
>> socket directly.
>
> Try using netlink in perl or python, it is quite difficult.

yep, ++
