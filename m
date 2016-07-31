From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 1/1] mwifiex: remove superfluous condition (2)
Date: Sun, 31 Jul 2016 15:03:03 +0300
Message-ID: <877fc2816w.fsf@purkki.adurom.net>
References: <1469962177-2432-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1469962177-2432-1-git-send-email-xypron.glpk-Mmb7MZpHnFY@public.gmane.org> (Heinrich
	Schuchardt's message of "Sun, 31 Jul 2016 12:49:37 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org> writes:

> We are using mac as source address in a memcpy.
> In the lines below we can assume mac is not NULL.
>
> Signed-off-by: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>

Please try to make the commit titles unique, for example you can use
function names or something else. Adding "(2)" is not the way to do
that.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
