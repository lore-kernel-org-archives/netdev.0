From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 2.6.11-rc4-netdev1 0/5] r8169: intro
Date: Tue, 22 Feb 2005 02:10:05 +0100
Message-ID: <20050222011005.GA32698@electric-eye.fr.zoreil.com>
References: <20050221235125.GD26248@electric-eye.fr.zoreil.com> <421A7C4E.6010404@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jdmason@us.ibm.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <421A7C4E.6010404@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
> Francois Romieu wrote:
> >2 - The current 2.6.11-rc4 r8169 driver would benefit from several patches
> >    availables in your -netdev serie:
> 
> 
> It's far too late for all but the most critical (crash-level) patches...

Fine with me. The "open after close" bug simply hangs the host.

--
Ueimor
