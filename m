From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH][V2] net: phy: marvell: make some functions static
Date: Fri, 2 Jun 2017 09:48:29 -0700
Message-ID: <5268b842-3784-36f7-7c6f-e1b4b670f8b5@gmail.com>
References: <20170602141334.26506-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170602141334.26506-1-colin.king@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 06/02/2017 07:13 AM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> functions m88e1510_get_temp_critical, m88e1510_set_temp_critical and
> m88e1510_get_temp_alarm can be made static as they not need to be
> in global scope.
> 
> Cleans up sparse warnings:
>  "symbol 'm88e1510_get_temp_alarm' was not declared. Should it be static?"
>  "symbol 'm88e1510_get_temp_critical' was not declared. Should it be
>   static?"
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
