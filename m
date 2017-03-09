From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: please add some examples to the ip man page
Date: Thu, 9 Mar 2017 08:17:43 -0700
Message-ID: <897a47d6-32c5-beef-c8fe-d7020c5956cc@cumulusnetworks.com>
References: <87pohsj42f.fsf@jidanni.org> <87r328tez5.fsf@jidanni.org>
 <20170309105647.GB29821@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Alexander Alemayhu <alexander@alemayhu.com>,
        =?UTF-8?B?56mN5Li55bC8IERhbiBKYWNvYnNvbg==?= <jidanni@jidanni.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:36433 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755001AbdCIPRx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 10:17:53 -0500
Received: by mail-it0-f45.google.com with SMTP id h10so130227511ith.1
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 07:17:53 -0800 (PST)
In-Reply-To: <20170309105647.GB29821@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/9/17 3:56 AM, Alexander Alemayhu wrote:
> On Wed, Mar 08, 2017 at 03:17:02PM +0800, 積丹尼 Dan Jacobson wrote:
>> I see.
>> Perhaps on the man page add
>> EXAMPLES
>>    See https://www.kernel.org/doc/Documentation/networking/vrf.txt
>>    https://www.google.com/search?q=ip+linux+command+usage+examples
>> (I thought the latter would be hopeless, but actually found lots!)
>>
> Actual examples in the page would better than links IMO.  git has some
> nice examples in gittutorial(7) and giteveryday(7). Maybe that can be
> good inspiration?

excellent opportunity for an aspiring writer / user to make a
contribution to improve iproute2.

git clone
git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
cd iproute2
<make changes>

commit, send to netdev.
