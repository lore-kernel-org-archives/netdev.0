From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [ethtool PATCH v2 4/4] ethtool: Enhancing link mode bits to
 support 25G/50G/100G
Date: Sun, 21 Aug 2016 08:39:15 -0700
Message-ID: <CACKFLinGC=OLZvsnZH_MXGeyqtyTpgWx_4fCqmohYvk0hyr4sQ@mail.gmail.com>
References: <1466970307-2411-5-git-send-email-vidya@cumulusnetworks.com>
 <CO2PR11MB00889D2C55C1E4C86D831C59970C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKWE-XqpkNprFcQj7wZEthmTTtDuU7657kjFP37EvrgCChncHw@mail.gmail.com>
 <20160802194957.GC24663@tuxdriver.com> <20160818182112.GB8347@tuxdriver.com> <CO2PR11MB008851C71DB6ACE14EC5A3EA97E90@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "John W. Linville" <linville@tuxdriver.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        "ben@decadent.org.uk" <ben@decadent.org.uk>,
        netdev <netdev@vger.kernel.org>,
        "bwh@kernel.org" <bwh@kernel.org>,
        David Miller <davem@davemloft.net>,
        "decot@googlers.com" <decot@googlers.com>,
        "bkenward@solarflare.com" <bkenward@solarflare.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "galp@mellanox.com" <galp@mellanox.com>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
        "dustin@cumulusnetworks.com" <dustin@cumulusnetworks.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33090 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754545AbcHUPjQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2016 11:39:16 -0400
Received: by mail-oi0-f41.google.com with SMTP id c15so122021511oig.0
        for <netdev@vger.kernel.org>; Sun, 21 Aug 2016 08:39:16 -0700 (PDT)
In-Reply-To: <CO2PR11MB008851C71DB6ACE14EC5A3EA97E90@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 21, 2016 at 7:44 AM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>> Ping?
>>
>> On Tue, Aug 02, 2016 at 03:49:57PM -0400, John W. Linville wrote:
>> > Are these revised patches still on their way?
>> >
>> > John
>> >
>> > On Sun, Jul 24, 2016 at 01:57:14AM -0700, Vidya Sagar Ravipati wrote:
>> > > Yuval,
>> > >     I will try to resubmit the patches this week with updated
>> > > comments
>> > >
>> > > Thanks
>> > > Vidya Sagar
>
> I can pick this up; But I'd need someone to fill me on which of the newer
> speeds could support autoneg [if any].

All of the new speeds support autoneg as far as I know.
