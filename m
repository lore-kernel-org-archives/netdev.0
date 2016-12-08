From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 4/5] liquidio VF timestamp
Date: Thu, 8 Dec 2016 23:09:39 +0200
Message-ID: <CAJ3xEMg3RC74PEF-6_mF96Wj-dHWW6simspOpxkiObgXBr67KA@mail.gmail.com>
References: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com> <1481230848-2393-5-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-oi0-f43.google.com ([209.85.218.43]:33096 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753028AbcLHVJk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 16:09:40 -0500
Received: by mail-oi0-f43.google.com with SMTP id w63so466371928oiw.0
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 13:09:40 -0800 (PST)
In-Reply-To: <1481230848-2393-5-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2016 at 11:00 PM, Raghu Vatsavayi
<rvatsavayi@caviumnetworks.com> wrote:
> Adds support for VF timestamp.

same here, what's the use case? do you have per VF HW clocks to set?
How it works if VF A does setup of X and VF B setup of Y
