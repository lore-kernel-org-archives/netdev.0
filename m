From: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <rafal@milecki.pl>
Subject: Re: [PATCH 2/3] net: ethernet: bgmac: unify code of the same family
Date: Fri, 03 Feb 2017 22:48:15 +0100
Message-ID: <cdd5a5472af15d6da11e80306424d8b9@milecki.pl>
References: <1486157970-6315-1-git-send-email-jon.mason@broadcom.com>
 <1486157970-6315-3-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486157970-6315-3-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-02-03 22:39, Jon Mason wrote:
> BCM471X and BCM535X are of the same family (from what I can derive from
> internal documents).  Group them into the case statement together, 
> which
> results in more code reuse.
> 
> Also, use existing helper variables to make the code a little more
> readable too.
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>

I'd like to review it / test it on few devices. Please give me weekend 
for
that.
