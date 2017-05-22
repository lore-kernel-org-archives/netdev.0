From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 11/20] net: dsa: move VLAN filtering setter
Date: Mon, 22 May 2017 12:33:43 -0700
Message-ID: <8386330a-d0e2-725d-2cbc-932b46c2605f@gmail.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
 <20170519210055.9366-12-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33690 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757148AbdEVTds (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 15:33:48 -0400
In-Reply-To: <20170519210055.9366-12-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2017 02:00 PM, Vivien Didelot wrote:
> Move the DSA port code which sets VLAN filtering on a port in port.c,
> where it belongs.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
