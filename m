From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH] ipoib: remove addrlen check for mc
	addresses
Date: Tue, 23 Mar 2010 12:30:34 +0200
Message-ID: <20100323103034.GC12224@mtldesk030.lab.mtl.com>
References: <20100322132138.GC2780@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, monis-smomgflXvOZWk0Htik3J/w@public.gmane.org,
	jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org
To: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100322132138.GC2780-YzwxZg+R7evMbnheQZGK0N5OCZ2W11yPFxja6HXR22MAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 22, 2010 at 02:21:39PM +0100, Jiri Pirko wrote:
> Finally this bit can be removed. Currently, after the bonding driver is
> changed/fixed (32a806c194ea112cfab00f558482dd97bee5e44e net-next-2.6),

Could you send a link to the git tree where I can find this commit and
the related fixes?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
