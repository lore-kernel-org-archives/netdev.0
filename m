From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: rtlwifi: Add missing newlines to RT_TRACE calls
Date: Fri,  8 Jul 2016 09:59:05 +0000 (UTC)
Message-ID: <20160708095905.632BA611B8@smtp.codeaurora.org>
References: <5677791872bfb47963780c198c825d882456720f.1466969647.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5677791872bfb47963780c198c825d882456720f.1466969647.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> RT_TRACE does not add a newline to the end of a message and always
> emits at KERN_DEBUG so these are susceptible to message interleaving
> from other processes without the newline.
> 
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

Thanks, 1 patch applied to wireless-drivers-next.git:

4713bd1c7407 rtlwifi: Add missing newlines to RT_TRACE calls

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9199581/

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
