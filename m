From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 0/4] 2.6.5-rc2-mm5 - r8169 queue
Date: Mon, 29 Mar 2004 22:35:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329223513.C4744@electric-eye.fr.zoreil.com>
References: <20040329193604.A4744@electric-eye.fr.zoreil.com> <20040329144034.3d943d12.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040329144034.3d943d12.ak@suse.de>; from ak@suse.de on Mon, Mar 29, 2004 at 02:40:34PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@suse.de> :
[...]
> Do you have any plans to convert it to use DAC?  

I should be able to cook up something shortly (i.e. during the week) so that
it is available in -mm or in a separate tree.

For anything else I'll go leveraging the 8139cp functions as
- it will not appear in 2.6.5 anyway so there is plenty of time ahead (TM);
- current -mm tree (+ a possible performance change) looks satisfactory
  enough so that it can be freezed in the meantime.

--
Ueimor
