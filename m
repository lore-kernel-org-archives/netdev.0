From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers:net:ethernet:emulex:benet: Use time_before_eq
 for time comparison
Date: Sun, 30 Apr 2017 22:34:25 -0400 (EDT)
Message-ID: <20170430.223425.472451891993812438.davem@davemloft.net>
References: <1493344139-6678-1-git-send-email-karim.eshapa@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
        sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kaim.eshapa@gmail.com
To: karim.eshapa@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1493344139-6678-1-git-send-email-karim.eshapa@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karim Eshapa <karim.eshapa@gmail.com>
Date: Fri, 28 Apr 2017 03:48:59 +0200

> Use time_before_eq for time comparison more safe and dealing
> with timer wrapping to be future-proof.
> 
> Signed-off-by: Karim Eshapa <kaim.eshapa@gmail.com>

Subject line has way too many subsystem prefixes, simply
"benet: " is sufficient.

And in situations where multiple subsystem prefixes are
appropriate, one must put a space after each one like
"one: two: three: ".

Thanks.
