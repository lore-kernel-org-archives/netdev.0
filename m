From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/1] iwlwifi: Remove duplicate inclusion of iwl-trans.h
 in pcie/drv.c
Date: Mon, 19 Nov 2012 15:09:41 +0100
Message-ID: <1353334181.18299.1.camel@jlt4.sipsolutions.net>
References: <1353325540-9338-1-git-send-email-sachin.kamat@linaro.org>
	 (sfid-20121119_125157_651111_5B3E39AD)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
To: Sachin Kamat <sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1353325540-9338-1-git-send-email-sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> (sfid-20121119_125157_651111_5B3E39AD)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-11-19 at 17:15 +0530, Sachin Kamat wrote:
> iwl-trans.h was included twice.

Thanks, I've picked this up.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
