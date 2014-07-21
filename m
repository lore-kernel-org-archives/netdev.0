From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 00/30] drivers/net: remove unnecessary break after
 return
Date: Mon, 21 Jul 2014 08:09:27 +0200 (CEST)
Message-ID: <1973473442.929183.1405922967308.open-xchange@webmail.nmp.skynet.be>
References: <1405865801-18806-1-git-send-email-fabf@skynet.be> <20140720.213102.1007291311502673484.davem@davemloft.net>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, linux-wireless@vger.kernel.org,
	joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	brcm80211-dev-list@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140720.213102.1007291311502673484.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 21 July 2014 at 06:31 David Miller <davem@davemloft.net> wrote:
>
>
> From: Fabian Frederick <fabf@skynet.be>
> Date: Sun, 20 Jul 2014 16:16:08 +0200
>
> > Second patchset after "remove unnecessary break after goto" addressing break
> > redundancy on drivers/net branch
> > (suggested by Joe Perches)
>
> All applied except the i40e patch, which did not apply to net-next at all.

Thanks a lot David.

Fabian
