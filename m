From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 23:28:27 -0800
Message-ID: <20041118232827.X2357@build.pdx.osdl.net>
References: <20041118230109.V2357@build.pdx.osdl.net> <Xine.LNX.4.44.0411190209090.8343-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Ross Kendall Axe <ross.axe@blueyonder.co.uk>,
	netdev@oss.sgi.com, Stephen Smalley <sds@epoch.ncsc.mil>,
	lkml <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261241AbUKSH2c@vger.kernel.org>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0411190209090.8343-100000@thoron.boston.redhat.com>; from jmorris@redhat.com on Fri, Nov 19, 2004 at 02:12:58AM -0500
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* James Morris (jmorris@redhat.com) wrote:
> For sendto():
>   "If the socket is connection-mode, dest_addr shall be ignored."

Yup, I read right past it, thanks.  Guess the standards have spoken ;-)

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
