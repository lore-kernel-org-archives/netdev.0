From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 7/9] net: dsa: define port types
Date: Thu, 26 Oct 2017 11:39:39 -0400
Message-ID: <87inf1q5ok.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com> <20171026152259.3123-8-vivien.didelot@savoirfairelinux.com> <20171026153611.GG1928@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:46228 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932246AbdJZPjl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:39:41 -0400
In-Reply-To: <20171026153611.GG1928@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

Jiri Pirko <jiri@resnulli.us> writes:

>>+	enum {
>>+		DSA_PORT_TYPE_UNUSED = 0,
>>+		DSA_PORT_TYPE_CPU,
>>+		DSA_PORT_TYPE_DSA,
>>+		DSA_PORT_TYPE_USER,
>
> Do you plan to expose this to userspace? How?

No. This is a DSA internal data for the moment.


Thanks,

        Vivien
