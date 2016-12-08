From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 2/5] liquidio VF vxlan
Date: Thu, 8 Dec 2016 23:08:13 +0200
Message-ID: <CAJ3xEMgrV4kjMY_SVJtk9VR85K7oSsSZGNQCi4UShogCKOq=hQ@mail.gmail.com>
References: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com> <1481230848-2393-3-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:35872 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbcLHVIO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 16:08:14 -0500
Received: by mail-oi0-f42.google.com with SMTP id v84so464733315oie.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 13:08:14 -0800 (PST)
In-Reply-To: <1481230848-2393-3-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2016 at 11:00 PM, Raghu Vatsavayi
<rvatsavayi@caviumnetworks.com> wrote:

> Adds VF vxlan offload support.

What's the use case for that? a VM running a VTEP, isn't that part
needs to run @ the host?

Or.
