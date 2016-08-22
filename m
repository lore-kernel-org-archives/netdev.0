From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phy: micrel: Reenable interrupts during resume for
 ksz9031
Date: Mon, 22 Aug 2016 16:35:08 -0700
Message-ID: <586f21cf-4ed4-48fc-c998-134678ca2043@gmail.com>
References: <1471899436-56626-1-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        brad.mouring@ni.com, nathan.sullivan@ni.com
To: Xander Huff <xander.huff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471899436-56626-1-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/22/2016 01:57 PM, Xander Huff wrote:
> Like the ksz8081, the ksz9031 has the behavior where it will clear the
> interrupt enable bits when leaving power down. This takes advantage of the
> solution provided by f5aba91.
> 
> Signed-off-by: Xander Huff <xander.huff@ni.com>
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
