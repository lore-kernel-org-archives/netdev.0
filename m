From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]: altq HFSC port
Date: Mon, 26 Jan 2004 23:27:06 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <4015943A.8020104@trash.net>
References: <Pine.GSO.4.42.0401261228290.22399-200000@stinky.trash.net>	<1075128375.1746.392.camel@jzny.localdomain> <20040126.102429.55841404.davem@redhat.com> <401560A6.7030803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <401560A6.7030803@trash.net>
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:

>
> This mail from Alan states that BSD without advertising clause linked
> with GPL ends up as GPL anyways, so I'm not sure if there is a problem.
> http://www.ussg.iu.edu/hypermail/linux/kernel/0110.2/0924.html
> I'm going to look for some more information before bothering the
> authors with License stuff again.
>
I've tried to get some more information and clear up my misconceptions, I can
of course not just relicense the existing code. Since mixing GPL and BSD without
advertising clause is not a problem if the resulting code _as a whole_ is GPL, I
think I only have to mark the pre-existing code being subject to the original
license. The code as a whole is not dual-licensed, so MODULE_LICENSE stays GPL.

Does that sound reasonable ?

Best regards,
Patrick


