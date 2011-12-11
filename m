From: wwguy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: iwlagn regression in v3.1.5
Date: Sun, 11 Dec 2011 10:23:35 -0800
Message-ID: <1323627815.1806.19.camel@wwguy-ubuntu>
References: <4EE4AEF4.2080702@udo.edu> <4EE4DB55.4090804@udo.edu>
	 <20111211174138.79e51fe8@x220.fritz.box>  <4EE4E152.2070204@udo.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Udo Steinberg <udo-VarzJz7m+TuRpAAqCnN02g@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrej Gelenberg <andrej.gelenberg-KJIyc1CJxjQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4EE4E152.2070204-KJIyc1CJxjQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2011-12-11 at 08:58 -0800, Andrej Gelenberg wrote:
> Hi,
> 
> this is pretty mean regression for the stable kernel. You may the fix 
> only for cards, which need it and not for all of them.

Could you elaborate more on the failure case and setup. this patch is to
address HT40 related problem which cause the iwlwifi firmware crash.

Thanks
Wey
> >


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
