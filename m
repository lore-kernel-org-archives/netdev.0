From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patches] 2.6.0-test9 - r8169 DMA API conversion
Date: Thu, 20 Nov 2003 20:38:37 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBD6C9D.3000207@pobox.com>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com> <3FB9A277.70309@pobox.com> <20031118135848.A2451@electric-eye.fr.zoreil.com> <3FBBA76B.4070606@pobox.com> <20031120010056.A19444@electric-eye.fr.zoreil.com> <20031121013637.B31929@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Brad House <brad_mssw@gentoo.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20031121013637.B31929@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The rx_copybreak didn't apply, but everything else did.  Thanks much. 
Just posted a new net-drivers-2.5-exp patch, to which you may sync with.

	Jeff
