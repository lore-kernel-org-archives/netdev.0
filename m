From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH v2 0/6] i40e: Add VF Port
 representator support for SR-IOV VFs
Date: Tue, 3 Jan 2017 20:45:03 +0000
Message-ID: <CAJpBn1x5ZqmG+a2hpTpS918XD8Rrj5c3UFAgm=Eu8aYv1TmnLA@mail.gmail.com>
References: <1483466874-2962-1-git-send-email-sridhar.samudrala@intel.com>
 <CAJ3xEMhcVnGH52rkyYbDOox89=+DNShDcPS-wr2a8VAgBZYMWw@mail.gmail.com>
 <CAKgT0UeKO+2jfnPQwGE6DbzxgLCLGPt+6WxduGhBXgBZz_14eQ@mail.gmail.com> <586C0868.2090007@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:34079 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761191AbdACUpn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 15:45:43 -0500
Received: by mail-qk0-f176.google.com with SMTP id h201so247885222qke.1
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 12:45:04 -0800 (PST)
In-Reply-To: <586C0868.2090007@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2017 at 8:24 PM, Samudrala, Sridhar
<sridhar.samudrala@intel.com> wrote:
> On 1/3/2017 12:04 PM, Alexander Duyck wrote:
>> On Tue, Jan 3, 2017 at 11:48 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Tue, Jan 3, 2017 at 8:07 PM, Sridhar Samudrala
>>> <sridhar.samudrala@intel.com> wrote:
>>>>
>>>> - Patch 4 adds a new type to metadata_dst to allow passing VF id to
>>>> lower device.
>>>
>>> again... I didn't get this one on my subscription, nor I see it in the
>>> archives
>>
>> It looks like netdev was on the list of email addresses for that
>> patch.  It might just be that the mail server has delayed it.
>
> That patch author is Jakub Kicinski. Is netdev blocking mails from
> jakub.kicinski@netronome.com?

I never had problems with sending emails or patches from this address, strange.
