From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/9] net: dsa: rename dsa_is_normal_port helper
Date: Thu, 26 Oct 2017 16:09:04 -0700
Message-ID: <5d222491-7348-4ffc-a54b-ca6cf865ffdf@gmail.com>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
 <20171026152259.3123-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:54104 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932351AbdJZXJI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 19:09:08 -0400
In-Reply-To: <20171026152259.3123-5-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2017 08:22 AM, Vivien Didelot wrote:
> This patch renames dsa_is_normal_port to dsa_is_user_port because "user"
> is the correct term in the DSA terminology, not "normal".
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
