From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable
Date: Thu, 15 Jan 2004 11:37:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115113700.166ddfb0.davem@redhat.com>
References: <OFC6D64AE0.CEE7DA5F-ON87256E1C.0068A56A@us.ibm.com>
	<20040116.041950.35757995.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xma@us.ibm.com, mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040116.041950.35757995.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 16 Jan 2004 04:19:50 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> In article <OFC6D64AE0.CEE7DA5F-ON87256E1C.0068A56A@us.ibm.com> (at Thu, 15 Jan 2004 11:09:47 -0800), Shirley Ma <xma@us.ibm.com> says:
> 
> > But if no applications use this value, and nothing is boken. It's not
> > harmful to change the kernel to provide MIBs in as-is format.
> 
> Shirley, nobody can prove that nothing will be broken. :-)

And also, the current situation is OK as long as this value we present now
can be converted into the desired value.  Is this the case?
