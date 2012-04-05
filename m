From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: kernel BUG at include/net/netns/generic.h:41
Date: Thu, 05 Apr 2012 20:14:04 +0400
Message-ID: <4F7DC4CC.9080502@parallels.com>
References: <20120328002346.GB3077@redhat.com> <20120402172600.GA3728@redhat.com> <1333390230.13718.34.camel@lade.trondhjem.org> <4F7DC37F.7090404@parallels.com> <20120405161241.GA23658@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Dave Jones <davej@redhat.com>,
	"Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19948 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848Ab2DEQOX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2012 12:14:23 -0400
In-Reply-To: <20120405161241.GA23658@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

05.04.2012 20:12, Dave Jones =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Thu, Apr 05, 2012 at 08:08:31PM +0400, Stanislav Kinsbursky wrote:
>
>   >  So, there are few questions to you, Dave:
>   >  1) can this happen (PipeFS mount attempt before SUNPRC module in=
sertion has
>   >  returned any value) in your case?
>
> I don't know enough of what systemd is doing to answer this.
>
>   >  2) how often do you experience this problem? Not every boot, I s=
uppose?
>   >  3) And is it easy for you to reproduce?
>
> It happens most the time, but not every time.
>

Ok, I'll send the patch soon.
Hope, it will help.

--=20
Best regards,
Stanislav Kinsbursky
