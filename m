From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8169 Lock-ups
Date: Tue, 13 Jan 2004 00:03:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113000357.D5983@electric-eye.fr.zoreil.com>
References: <1073507006.5151.61.camel@localhost> <20040107232034.A22930@electric-eye.fr.zoreil.com> <1073596694.6378.6.camel@localhost> <4001080D.3090401@pobox.com> <20040111124957.A18068@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dpollock@acm.org, damouse@ntlworld.com, brad@mainstreetsoftworks.com,
        kinetik@orcon.net.nz
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040111124957.A18068@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sun, Jan 11, 2004 at 12:49:57PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Re,

  latest pile of r8169 related patches against 2.6.1-bk1 available at
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.1-bk1

If you want to help:
apply r8169-dma-api-tx.patch
apply r8169-dma-api-rx-buffers.patch
apply r8169-dma-api-rx-buffers-ahum.patch
apply r8169-dma-api-rx-buffers-argl.patch <-- bug removed, sing and rejoice !
apply r8169-rx-fill-typo.patch
apply r8169-start-xmit-fixes.patch
apply r8169-dma-api-tx-buffers.patch
apply r8169-rx_copybreak.patch

-> does it work here ?

apply r8169-mac-phy-version.patch
apply r8169-buggy-devinitdata.patch

-> and here ?

--
Ueimor
