From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] socket.7: Document some BPF-related socket options
Date: Thu, 25 Feb 2016 12:56:13 -0800
Message-ID: <20160225205610.GA38279@ast-mbp.thefacebook.com>
References: <1456432065-3362-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Craig Gallek <kraigatgoog-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1456432065-3362-1-git-send-email-kraigatgoog-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 25, 2016 at 03:27:45PM -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> Document the behavior and the first kernel version for each of the
> following socket options:
> SO_ATTACH_FILTER
> SO_ATTACH_BPF
> SO_ATTACH_REUSEPORT_CBPF
> SO_ATTACH_REUSEPORT_EBPF
> SO_DETACH_FILTER
> SO_DETACH_BPF
> 
> Signed-off-by: Craig Gallek <kraig-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks! Looks good to me.
Acked-by: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
