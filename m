From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch linux-2.6.12-rc3-mm3 1/7] r8169: de-obfuscate supported
 PCI ID
Date: Sun, 15 May 2005 18:14:46 -0400
Message-ID: <4287C9D6.1060004@pobox.com>
References: <20050504221057.1e02a402.akpm@osdl.org> <20050505115502.GA4414@electric-eye.fr.zoreil.com> <20050505110052.62c1c2cb.akpm@osdl.org> <20050505225656.GA11200@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050505225656.GA11200@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All seven look OK, but it failed on the first patch:

[jgarzik@pretzel netdev-2.6]$ dotest /g/tmp/mbox

Applying 'r8169: de-obfuscate supported PCI ID'

patching file drivers/net/r8169.c
Hunk #1 FAILED at 174.
1 out of 1 hunk FAILED -- saving rejects to file drivers/net/r8169.c.rej
