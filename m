From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [oss-drivers] Re: [RFC 3/4] nfp: make use of extended ack message
 reporting
Date: Wed, 26 Apr 2017 09:03:23 -0400
Message-ID: <646e0fb0-1f10-f4d0-936c-7fdf96b6cc43@mojatatu.com>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com>
 <20170425080644.122536-4-jakub.kicinski@netronome.com>
 <9765d004-de19-7cf2-fcfc-1d2e72cded43@mojatatu.com>
 <20170425.102022.219410555949403896.davem@davemloft.net>
 <20170426111315.GC28251@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        johannes@sipsolutions.net, dsa@cumulusnetworks.com,
        daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        bblanco@gmail.com, john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36486 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S3000008AbdDZND2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 09:03:28 -0400
Received: by mail-io0-f196.google.com with SMTP id x86so352473ioe.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 06:03:28 -0700 (PDT)
In-Reply-To: <20170426111315.GC28251@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-26 07:13 AM, Simon Horman wrote:

> I don't feel strongly about this and perhaps it can be revisited at some
> point but perhaps it would be worth documenting that he strings do not
> form part of the UAPI as my expectation would have been that they do f.e. to
> facilitate internationalisation.
>

I thought people script against what iproute2 outputs today. We
may have to change habits.

cheers,
jamal
