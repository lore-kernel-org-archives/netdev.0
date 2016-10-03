From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [v2] mwifiex: report wakeup for wowlan
Date: Mon,  3 Oct 2016 13:04:11 +0000 (UTC)
Message-ID: <20161003130411.68CD2618B2@smtp.codeaurora.org>
References: <1475027104-17423-1-git-send-email-rajatja@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Wei-Ning Huang <wnhuang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Brian Norris <briannorris-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Eric Caruso <ejcaruso-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, rajatxjain-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475027104-17423-1-git-send-email-rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> Enable notifying wakeup source to the PM core in case of
> a wake on wireless LAN event.
> 
> Signed-off-by: Wei-Ning Huang <wnhuang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Tested-by: Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Reviewed-by: Eric Caruso <ejcaruso-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Acked-by: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>

The commit log doesn't give any background info. Does this fix a bug or
why is it needed?

Patch set to Changes Requested.

-- 
https://patchwork.kernel.org/patch/9353051/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
