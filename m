From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH iproute2 net-next V5] tc: flower: Refactor matching flags
 to be more user friendly
Date: Thu, 19 Jan 2017 16:53:05 +0200
Message-ID: <ae2dbf75-7a36-3b27-b2eb-76ecb4daa725@mellanox.com>
References: <1484836073-47019-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Blakey <paulb@mellanox.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Benc <jbenc@redhat.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0056.outbound.protection.outlook.com ([104.47.1.56]:22256
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753331AbdASPIV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 10:08:21 -0500
In-Reply-To: <1484836073-47019-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/19/2017 4:27 PM, Paul Blakey wrote:
> Hi, added a framework to add new flags more easily, such
> as the upcoming tcp_flags (see kernel cls_flower), and other ip_flags.

FWIW, just wanted to make a note that I have the patches for tcp_flags 
under the works, so if someone needs them urgently send me email, want 
to avoid wasting your time implementing this..

Or.
