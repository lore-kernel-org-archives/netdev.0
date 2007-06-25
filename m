From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Scaling Max IP address limitation
Date: Mon, 25 Jun 2007 15:44:28 +0300
Message-ID: <7e63f56c0706250544u78353454y44f4aab12a9e3fa8@mail.gmail.com>
References: <467EA7C1.4080006@rossove.com>
	 <20070624110236.fa36b2f9.akpm@linux-foundation.org>
	 <7e63f56c0706241259u6e123ed6yc02b76f0260adaa5@mail.gmail.com>
	 <467F063A.2030805@rossove.com>
	 <7e63f56c0706250147w508d3aeay5f7aaca8215953c8@mail.gmail.com>
	 <Pine.LNX.4.64.0706251130320.11964@fbirervta.pbzchgretzou.qr>
	 <7e63f56c0706250241q19c6cb49yb846a38eb10a53e6@mail.gmail.com>
	 <Pine.LNX.4.64.0706251437130.3137@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: djones@rossove.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "Andrew Morton" <akpm@linux-foundation.org>
To: "Jan Engelhardt" <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:59175 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755636AbXFYMo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 08:44:29 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1438540wxc
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 05:44:28 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0706251437130.3137@fbirervta.pbzchgretzou.qr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/25/07, Jan Engelhardt <jengelh@computergmbh.de> wrote:
>
> On Jun 25 2007 12:41, Robert Iakobashvili wrote:
> >> > I am getting after initial successes some errors:
> >> > "rtnl_talk(): RTNETLINK answers: Cannot allocate memory"
> >> > and
> >> > #ip addr | wc-l is 8194.
> >>
> >> I'd be surprised if it was 4096 on x86 and 8192 on x86_64...
> >
> > Missed to mention: the CPU is Pentium-4.
>
> That's like saying you've got a SPARC. Or a MIPS. Or a PPC.
> (I can't infer from your answer whether that is running 32 or 64-bit
> kernel, because there are P4s with and without 64-bit extensions.)

32/32

>         Jan
> --
>


-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...........................................................
http://curl-loader.sourceforge.net
A web testing and traffic generation tool.
