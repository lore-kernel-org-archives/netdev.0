From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Wed, 8 Feb 2017 06:27:46 +0100
Message-ID: <20170208052746.GA1779@localhost.localdomain>
References: <20170207140144.GA11233@localhost>
 <02874ECE860811409154E81DA85FBB5857D6DC87@ORSMSX115.amr.corp.intel.com>
 <BBA8C11E-44DF-4693-957F-0354BEC75FC3@me.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Miroslav Lichvar <mlichvar@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Benc <jbenc@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Denny Page <dennypage@me.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37735 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751131AbdBHF2m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 00:28:42 -0500
Received: by mail-wm0-f49.google.com with SMTP id v77so177986403wmv.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 21:27:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <BBA8C11E-44DF-4693-957F-0354BEC75FC3@me.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 05:52:52PM -0800, Denny Page wrote:
> Most, but not all. The TI DP83630 doesn’t support timestamping for all packets, but it does support either PTP or NTP:

That is the one and only device that explicitly supports NTP. This is
a nice idea, of course, but it just did not take off among other
products.

Thanks,
Richard
