From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: realtek r8169 + kernel 2.4.24 (openmosix)
Date: Thu, 9 Dec 2004 01:50:15 +0100
Message-ID: <20041209005015.GA25868@electric-eye.fr.zoreil.com>
References: <20041205122414.GA22383@electric-eye.fr.zoreil.com> <200412051317.iB5DHrOL026570@kane.otenet.gr> <20041205135132.GA23262@electric-eye.fr.zoreil.com> <20041206234131.GA12838@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261358AbULIAvQ@vger.kernel.org>
To: Nicholas Papadakos <panic@quake.gr>
Content-Disposition: inline
In-Reply-To: <20041206234131.GA12838@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[unstable backport of the r8169 driver]

Nicholas, can you give a try at the patch below against vanilla 2.4.28 ?
http://www.fr.zoreil.com/people/francois/misc/20041209-2.4.28-r8169.c-test.patch

This patch does not trivially crash and you should be able to set the
mtu around 7200 bytes.

The detail of the (43) patches is available at:
http://www.fr.zoreil.com/linux/kernel/2.4.x/2.4.28/r8169.

--
Ueimor
