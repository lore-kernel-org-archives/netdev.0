From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 07/20] net: dsa: change scope of VLAN filtering
 setter
Date: Mon, 22 May 2017 12:27:44 -0700
Message-ID: <242643c5-97ba-7c39-3e41-3ca63a283fe2@gmail.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
 <20170519210055.9366-8-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33515 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751914AbdEVT1s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 15:27:48 -0400
In-Reply-To: <20170519210055.9366-8-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2017 02:00 PM, Vivien Didelot wrote:
> Change the scope of the switchdev VLAN filtering attribute setter from
> the DSA slave device to the generic DSA port, so that the future
> port-wide API can also be used for other port types, such as CPU and DSA
> links.
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
