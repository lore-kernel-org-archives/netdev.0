From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/4] net: macb: Add support for PTP timestamps in DMA
 descriptors
Date: Tue, 09 May 2017 09:25:18 -0400 (EDT)
Message-ID: <20170509.092518.1737282249706066693.davem@davemloft.net>
References: <1494321885-14384-1-git-send-email-rafalo@cadence.com>
        <20170509120434.GA9368@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org, nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, andrei.pistirica-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org
To: richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170509120434.GA9368-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 9 May 2017 14:04:34 +0200

> On Tue, May 09, 2017 at 10:24:45AM +0100, Rafal Ozieblo wrote:
>> This patch adds support for PTP timestamps in
>> DMA buffer descriptors. It checks capability at runtime
>> and uses appropriate buffer descriptor.
>> 
>> Signed-off-by: Rafal Ozieblo <rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>
> 
> You posted this series once before, on April 13, 2017.  That makes
> this v2.  Please add v2 in the subject line, eg. [PATCH v2 1/4].
> 
> Also, add a cover letter [0/4] that summarizes the changes between v1
> and v2 of the series.

Please don't ask someone to repost a series targetting net-next
right now when that tree is currently closed for submissions.

Thank you.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
