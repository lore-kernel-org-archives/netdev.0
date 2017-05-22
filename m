From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 09/20] net: dsa: move port state setters
Date: Mon, 22 May 2017 12:31:38 -0700
Message-ID: <ae20ab61-337e-cb61-1943-8bb93b038b00@gmail.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
 <20170519210055.9366-10-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34453 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761340AbdEVTbm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 15:31:42 -0400
In-Reply-To: <20170519210055.9366-10-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2017 02:00 PM, Vivien Didelot wrote:
> Add a new port.c file to hold all DSA port-wide logic. This patch moves
> in the code which sets a port state.

Usually, I am not fond of moving code around, but in this case, this
makes the whole directory structure nicer.

> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
