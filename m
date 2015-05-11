From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 2/2] adm8211: fix the possible pci cache line sizes inside switch-case
Date: Mon, 11 May 2015 13:38:58 +0300
Message-ID: <87vbfzjt4t.fsf@kamboji.qca.qualcomm.com>
References: <20150505224020.GA3805@bytefire-computer>
	<87wq0ms3mv.fsf@kamboji.qca.qualcomm.com>
	<20150506063241.GA3042@bytefire-computer>
	<87k2wflj7p.fsf@kamboji.qca.qualcomm.com>
	<2CBE2DDF-92E5-45C9-95F8-C5CF918D12D9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "joe\@perches.com" <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	"linux-wireless\@vger.kernel.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2CBE2DDF-92E5-45C9-95F8-C5CF918D12D9-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Okash Khawaja's
	message of "Mon, 11 May 2015 09:48:54 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Sure, I'll create v2 of the patch with updated commit log. 
>
> Since it's part of a patch set, do you want me to send both the
> patches in the patch set together as v2 or just this patch?

Please resend the whole patchset as v2, less problems that way.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
