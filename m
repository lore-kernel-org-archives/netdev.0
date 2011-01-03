From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Date: Mon, 3 Jan 2011 14:38:50 -0600
Message-ID: <4D2233DA.1070801@parallels.com>
References: <1293628470-28386-1-git-send-email-kas@openvz.org> <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com> <20101230085139.GA29697@shutemov.name> <4D1C4C7C.6050606@parallels.com> <20101230094433.GB29697@shutemov.name> <4D1C5953.6020200@parallels.com> <20101230104416.GA31824@shutemov.name> <AANLkTim2QrkSW0HufD5wp=-8ikwydN5SUS+fdWK6JHqb@mail.gmail.com> <20101230114514.GA31976@shutemov.name> <4D1C809B.30405@parallels.com> <20101231130329.GA3610@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	<linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101231130329.GA3610-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/31/2010 07:03 AM, Kirill A. Shutemov wrote:

> EXPORT_SYMBOL_GPL(get_rpc_pipefs);
>
> Something like this? Patch to replace patch #10 attached.

Looks good to me.  Thanks.

acked-by: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

Rob


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
