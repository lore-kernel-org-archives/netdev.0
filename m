From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/3] Completed requested changes
Date: Wed, 01 Nov 2017 11:02:21 +0900 (KST)
Message-ID: <20171101.110221.824397006359737702.davem@davemloft.net>
References: <1509473668-4091-1-git-send-email-manish.kurup@verizon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        aring@mojatatu.com, mrv@mojatatu.com, manish.kurup@verizon.com
To: kurup.manish@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACC1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:02:27 -0400
In-Reply-To: <1509473668-4091-1-git-send-email-manish.kurup@verizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Kurup <kurup.manish@gmail.com>
Date: Tue, 31 Oct 2017 14:14:28 -0400

> Modified the netronome drivers (flower action) to use the VLAN helper functions
> instead of dereferencing the structure directly. This is required for the VLAN
> action patch.
> 
> Could you please review?

Please simplify the subsystem prefixes in your Subject lines, they are
very long.

"act_vlan: " and "nfp: " are more than sufficient.

Thank you.
