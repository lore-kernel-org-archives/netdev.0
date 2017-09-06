From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: hung task in mac80211
Date: Wed, 06 Sep 2017 17:11:51 +0200
Message-ID: <1504710711.23905.17.camel@sipsolutions.net>
References: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg@mail.gmail.com>
         <1504702728.13457.17.camel@sipsolutions.net>
         <CAGnkfhyBMKT-Tf10NxjN40Znuj7OK2pSM3qLUidPSkQqh8gjwQ@mail.gmail.com>
         (sfid-20170906_170509_159201_9F9A1278)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Matteo Croce <mcroce@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGnkfhyBMKT-Tf10NxjN40Znuj7OK2pSM3qLUidPSkQqh8gjwQ@mail.gmail.com> (sfid-20170906_170509_159201_9F9A1278)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-09-06 at 17:04 +0200, Matteo Croce wrote:
> 
> I confirm that this patch fixes the hang too.

Cool, I'll go apply it.

> I'm curious to see if there are noticeable performance differences
> between the two solutions.

Nope, you hit this code path essentially once.

johannes
