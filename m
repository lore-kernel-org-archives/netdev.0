From: Joseph Golio <golio@vieo.com>
Subject: [Fwd: IPoIB]
Date: Thu, 30 May 2002 07:32:32 -0500
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CF61BE0.BDF0F05B@vieo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Joseph Golio wrote:

To whom it may concern,


I originally sent this note to Alan Cox, but he has suggested that I send it to
you folks. I'm
new at this process so please bare with me...

So, here goes.

> Alan,
>
>     I have a question. I am working on developing a Linux driver for IP over
> Infiniband (IPoIB) and
>     have run into an issue that I need your advice. The draft standard from the
> IETF on IPoIB
>     encapsulation and address resolution over Infiniband networks (see the link
> below - section 6.1.1)
>     defines the hardware address as being 20 bytes in length. It appears that
> the "netdevice.h" file in
>     Linux has MAX_ADDR_LEN set to 7 (at least in my version which is SuSe 7.3 -
> kernel 2.4.4).
>
> http://www.ietf.org/internet-drafts/draft-ietf-ipoib-ip-over-infiniband-01.txt
>
>     Obviously, this will not.
>
>     What do you suggest as a good solution to this problem ?
>
>     Thanks in advance for a quick response.
>
> Thanks for your time,
>
> Joe Golio
> golio@vieo.com
> 651-698-9350 (ext. 111)
> VIEO Inc.
>
> VIEO: The Adaptive Application Infrastructure Management (AAIM) Company
