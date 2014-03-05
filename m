From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCHv3 net-next 00/31] Misc. fixes for cxgb4 and iw_cxgb4
Date: Wed, 5 Mar 2014 21:39:20 +0200
Message-ID: <CAJZOPZL05TY6qSdBDoS6aCj=_uepkZTX5+fVvnHTsCsKKMqgSQ@mail.gmail.com>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>
	<20140304.132226.75524344104026791.davem@davemloft.net>
	<20140305053024.GA23862@hariprasad-pc>
	<9E6E5D92-7F25-49A3-BEB5-424CCE2F725D@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Hariprasad S <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9E6E5D92-7F25-49A3-BEB5-424CCE2F725D-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 5, 2014 at 9:15 PM, Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org> wrote:
>   Yes, thanks mightily for your help and advice and sorry for the size of the updates.  Hari has taken on the very difficult task of synchronizing our out-of-kernel development branch with the in-kernel code.  These two code bases have drifted apart quite a bit because of the difficulty of translating our out-of-kernel changes into the in-kernel driver which uses completely different symbolic register constants.

Can you explain this in a little bit more details? what's the source
of the need to use two different sets of symbolic register constants?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
