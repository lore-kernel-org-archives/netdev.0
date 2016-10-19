From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 2/6] net: use core MTU range checking in
 wireless drivers
Date: Wed, 19 Oct 2016 16:28:07 +0200
Message-ID: <1476887287.10092.13.camel@sipsolutions.net>
References: <20161019023333.15760-1-jarod@redhat.com>
         <20161019023333.15760-3-jarod@redhat.com>
         <1476862713.5927.0.camel@sipsolutions.net>
         <20161019142706.GE18569@redhat.com> (sfid-20161019_162711_480451_2E690F9F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Maya Erez <qca_merez@qca.qualcomm.com>,
        Simon Kelley <simon@thekelleys.org.uk>,
        Stanislav Yakovlev <stas.yakovlev@gmail.com>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161019142706.GE18569@redhat.com> (sfid-20161019_162711_480451_2E690F9F)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > I guess we should do the same in net/mac80211/iface.c?
> 
> Yeah. I thought I'd located all places this needed to happen, but
> obviously not. I'll get this added and do another sweep for others I
> might have missed.

No worries. I can also do it if you prefer, just wanted to ask :)

johannes
