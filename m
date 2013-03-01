From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH 0/5] net: low latency Ethernet device polling
Date: Fri, 1 Mar 2013 14:57:40 -0800
Message-ID: <CA+mtBx8QS8Gkue6Pu8qw8v0q0zn-j1xLSZhxZ5yP=UTbJe4yaQ@mail.gmail.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
	<20130301.162400.1645765127882618751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eliezer.tamir@linux.jf.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	andi@firstfloor.org, hpa@zytor.com, eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130301.162400.1645765127882618751.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This is exactly the kind of approach that makes sense rather than
> trying to put entire TCP stacks in the network card firmware.
>
And should also obviate the need to put a full TCP stack in user space!

> Thanks again for doing this work and I look forward to applying
> this stuff once all the kinks are worked out.  The folks in the
> Intel NIC group continue to impress me.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
