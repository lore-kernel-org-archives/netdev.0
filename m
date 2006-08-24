From: "Jeff Kirsher" <tarbal@gmail.com>
Subject: Re: [PATCH] ethtool v4: add autoneg advertise feature
Date: Thu, 24 Aug 2006 08:54:33 -0700
Message-ID: <9929d2390608240854y65c5f012hc6aa25c0d3507876@mail.gmail.com>
References: <9929d2390608240822w7a586d7ai679d2af0be7c7213@mail.gmail.com>
	 <1551EAE59135BE47B544934E30FC4FC093FAA2@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>,
	"John Ronciak" <john.ronciak@intel.com>,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:58897 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S965055AbWHXPye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 11:54:34 -0400
Received: by ug-out-1314.google.com with SMTP id m3so545479ugc
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2006 08:54:33 -0700 (PDT)
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093FAA2@NT-IRVA-0751.brcm.ad.broadcom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/24/06, Michael Chan <mchan@broadcom.com> wrote:
>
> It is more flexible, but less intuitive.  The user now has to
> remember hex values instead of the more intuitive speed and
> duplex.  Perhaps we can keep the old method of using speed and
> duplex, while adding the new method of specifying hex values?
>
>

That sounds fine to me.  I can send a modified patch, keeping the old
method available to users.

-- 
Cheers,
Jeff
