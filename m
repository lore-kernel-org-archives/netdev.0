From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch linux-2.6.12-rc3-mm3 1/7] r8169: de-obfuscate supported PCI ID
Date: Tue, 17 May 2005 22:48:11 +0200
Message-ID: <20050517204811.GA12936@electric-eye.fr.zoreil.com>
References: <20050504221057.1e02a402.akpm@osdl.org> <20050505115502.GA4414@electric-eye.fr.zoreil.com> <20050505110052.62c1c2cb.akpm@osdl.org> <20050505225656.GA11200@electric-eye.fr.zoreil.com> <4287C9D6.1060004@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4287C9D6.1060004@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
> All seven look OK, but it failed on the first patch:
> 
> [jgarzik@pretzel netdev-2.6]$ dotest /g/tmp/mbox
> 
> Applying 'r8169: de-obfuscate supported PCI ID'
> 
> patching file drivers/net/r8169.c
> Hunk #1 FAILED at 174.
> 1 out of 1 hunk FAILED -- saving rejects to file drivers/net/r8169.c.rej

Yes. In the meantime, -mm was applied:
[patch 2.6.12-rc2-mm3 1/1] r8169: new PCI id

Should I send a serie of patches against
126fa4b9ca5d9d7cb7d46f779ad3bd3631ca387c to update it to r8169-mm-latest ?

--
Ueimor
