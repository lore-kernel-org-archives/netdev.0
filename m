From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] Prefix List and O/M flags against 2.4.21
Date: Fri, 18 Jul 2003 00:47:01 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030718.004701.11546819.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0307171413100.1353-100000@DYN318430.beaverton.ibm.com>
	<20030718.002209.104303756.yoshfuji@linux-ipv6.org>
	<3F17245D.9040806@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, davem@redhat.com, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: krkumar@us.ibm.com
In-Reply-To: <3F17245D.9040806@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <3F17245D.9040806@us.ibm.com> (at Thu, 17 Jul 2003 15:34:05 -0700), Krishna Kumar <krkumar@us.ibm.com> says:

> have any knowledge of using this new interface. If you prefer, I can split the
> patch for prefix list vs O/M bits so that the former is accepted without any
> issues. Someone else can modify the O/M to suit new needs. Does that sound OK
> with you ?

Yes, please split up the patch.


>  > At least, new RTM_xxx should not be restricted to get such flags.
> 
> That's why I had suggested that we can use RTM_GETLNKINFO with more information,
> like RTA_IFFLAGS, and other things like stats or whatever. That can be done
> easily enough and still be functionally complete. I just don't have any idea
> about this new interface.
> 
> Is this still a problem ?

Hmm, I might miss something.
Anyway, it seems we're reaching consensus.

--yoshfuji
