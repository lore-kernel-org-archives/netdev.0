From: Kumar Sanghvi <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH V2 02/10] cxgb4: Common platform specific changes for DB
 Drop Recovery
Date: Fri, 28 Oct 2011 23:52:35 +0530
Message-ID: <20111028182234.GA11554@kumars-PC.asicdesigners.com>
References: <1319130620-9240-1-git-send-email-vipul@chelsio.com>
 <8A71B368A89016469F72CD08050AD3340A3D3120@maui.asicdesigners.com>
 <CAL1RGDXoeJNYz3R58bU-ixRyY1uKNgGPdUrWZ4nbcuyRDjL6Cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Felix Marti <felix-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Divy Le Ray <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	Dimitrios Michailidis <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
To: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAL1RGDXoeJNYz3R58bU-ixRyY1uKNgGPdUrWZ4nbcuyRDjL6Cg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Roland,

On Fri, Oct 28, 2011 at 10:59:47 -0700, Roland Dreier wrote:
> On Thu, Oct 20, 2011 at 10:18 AM, Felix Marti <felix-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org> wrote:
> > Don't add stuff to the t4fw_interface.h, that is owned by firmware.
> 
> Vipul, do you plan to respin to handle Felix's comment?
> 
>  - R.
Vipul is on leave, so replying on his behalf.

Vipul did a respin of this patch, and posted the V3 version.
Its available here:
http://www.mail-archive.com/linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg09659.html

Thanks,
Kumar.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
