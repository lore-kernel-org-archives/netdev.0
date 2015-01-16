From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] bluetooth: Remove unused function
Date: Fri, 16 Jan 2015 13:08:47 +0200
Message-ID: <20150116110847.GA4102@t440s.lan>
References: <1420386914-12885-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1420386914-12885-1-git-send-email-rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rickard,

On Sun, Jan 04, 2015, Rickard Strandqvist wrote:
> Remove the function hci_conn_change_link_key() that is not used anywhere.
> 
> This was partially found by using a static code analysis program
> called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
> ---
>  include/net/bluetooth/hci_core.h |    1 -
>  net/bluetooth/hci_conn.c         |   15 ---------------
>  2 files changed, 16 deletions(-)

Applied to the bluetooth-next tree. Thanks.

Johan
