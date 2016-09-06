From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: Re: [ethtool PATCH v1 0/2] ethtool: add support for 1000BaseX and
 missing 10G link mode
Date: Tue, 6 Sep 2016 13:39:11 -0700
Message-ID: <CAKWE-XrUBUhodTmDwS2jM8RvmtSGPA7RA33=_QxEEZVuPVi8zQ@mail.gmail.com>
References: <1472453810-47177-1-git-send-email-vidya@cumulusnetworks.com>
 <20160906201614.GE2909@tuxdriver.com> <CAKWE-XrhYQ+bL2mxMftonqpGFGDaRTsvhzbhP3enap0C6+BT3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, bwh@kernel.org,
        David Miller <davem@davemloft.net>,
        David Decotigny <decot@googlers.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Dustin Byford <dustin@cumulusnetworks.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f182.google.com ([209.85.213.182]:32792 "EHLO
        mail-yb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933628AbcIFUjM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 16:39:12 -0400
Received: by mail-yb0-f182.google.com with SMTP id d205so77538288ybh.0
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 13:39:12 -0700 (PDT)
In-Reply-To: <CAKWE-XrhYQ+bL2mxMftonqpGFGDaRTsvhzbhP3enap0C6+BT3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will send out man page fix. Missed it.

On Tue, Sep 6, 2016 at 1:32 PM, Vidya Sagar Ravipati
<vidya@cumulusnetworks.com> wrote:
> Will send out man page fix too. Missed it.
>
> On Tue, Sep 6, 2016 at 1:16 PM, John W. Linville <linville@tuxdriver.com>
> wrote:
>>
>> On Sun, Aug 28, 2016 at 11:56:48PM -0700, Vidya Sagar Ravipati wrote:
>> > From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
>> >
>> > This patchset enhances ethtool link mode bitmap to include
>> > missing interface modes for 1G/10G speeds
>> >
>> > Vidya Sagar Ravipati (2):
>> >   ethtool-copy.h:sync with net
>> >   ethtool: add support for 1000BaseX and missing 10G link mode
>> >
>> >  ethtool-copy.h | 11 +++++++++--
>> >  ethtool.c      | 19 +++++++++++++++++++
>> >  2 files changed, 28 insertions(+), 2 deletions(-)
>> >
>> > --
>> > 2.1.4
>>
>> LGTM -- applied
>>
>> Would you care to fix-up the man page as well?
>>
>> John
>> --
>> John W. Linville                Someday the world will need a hero, and
>> you
>> linville@tuxdriver.com                  might be all we have.  Be ready.
>
>
