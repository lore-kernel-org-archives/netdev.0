From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: e1000 performance hack for ppc64 (Power4)
Date: Fri, 13 Jun 2003 16:52:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107D93A@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <haveblue@us.ibm.com>, <hdierks@us.ibm.com>, <dwg@au1.ibm.com>,
   <linux-kernel@vger.kernel.org>, <milliner@us.ibm.com>,
   <ricardoz@us.ibm.com>, <twichell@us.ibm.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Anton Blanchard" <anton@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > Why not instead find out if it's possible to have the e1000 
> > fetch the entire cache line where the first byte of the
> > packet resides?  Even ancient designes like SunHME do that.
> 
> Rusty and I were wondering why the e1000 didnt do that exact thing.
> 
> Scott: is it possible to enable such a thing?

I thought the answer was no, so I double checked with a couple of
hardware guys, and the answer is still no.

-scott
