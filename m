From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [PATCH 2.6.6-bk8] pcnet32: limit frames received during
Date: Mon, 24 May 2004 11:30:46 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405241830.i4OIUkr24417@DYN318364BLD.beaverton.ibm.com>
References: <20040524112436.5ce66cc1@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org (Stephen Hemminger)
In-Reply-To: <20040524112436.5ce66cc1@dell_ss3.pdx.osdl.net> from "Stephen Hemminger" at May 24, 2004 11:24:36 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'll add that to my list.

> > The current code will allow an infinite number of frames to be received
> > during one interrupt.  Tested ia32 and ppc64.
> 
> How about converting to support NAPI?
> 

-- 
Don Fry
brazilnut@us.ibm.com
