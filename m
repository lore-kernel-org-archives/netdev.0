From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH] TSO Reloaded
Date: Thu, 5 May 2005 22:53:09 -0500
Message-ID: <200505052253.10301.jdmason@us.ibm.com>
References: <20050504230731.12be1bc3.davem@davemloft.net> <200505051756.25186.jdmason@us.ibm.com> <20050505154955.0dcb4b38.davem@davemloft.net>
Reply-To: jdmason@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050505154955.0dcb4b38.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 05 May 2005 05:49 pm, David S. Miller wrote:
> On Thu, 5 May 2005 17:56:25 -0500
>
> Jon Mason <jdmason@us.ibm.com> wrote:
> > I can give it a quick sniff on e1000 and r8169 (on amd64), though only to
> > verify that its works (ie, no real perf).  Is that acceptable?
>
> Yes.

It worked fine for both r8169 and e1000 on my amd64 box (running 
2.6.12-rc3-mm2). 
