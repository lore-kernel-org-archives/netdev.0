From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: IPsec AH use of ahash
Date: Wed, 30 Jan 2013 23:16:31 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1301302303180.11666@nerf07.vanv.qr>
References: <650108746.93086.1358690064783.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexander Holler <holler@ahsoftware.de>,
	Borislav Petkov <bp@alien8.de>,
	Eric Dumazet <erdnetdev@gmail.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>,
	Mike Galbraith <bitbucket@online.de>
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <650108746.93086.1358690064783.JavaMail.root@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sunday 2013-01-20 14:54, Tom St Denis wrote:
>> 
>> > You should really try running checkpatch.pl over code that's
>> > already in the kernel before you call out new contributors on it.
>> >
>> > How is this supposed to not be adversarial when I can't even use
>> > the Kernel source itself as a reference?
>> 
>> In case of the kernel the chicken and egg problem can be answered
>> without any questions, most source existed before checkpatch.pl
>> (evolved
>> to the current state).
>
>We clearly have different interpretations of the word "maintainer"
>then... If they're not maintaining the code then are they really the
>maintainers of it?

Maintainers maintain code. From own experience - I too have some
projects that are *only* "maintained" - that includes maintaining the
status quo, keeping it compiling and taking patches that require no
more than 5 minutes to think about.

To support users, especially ones with fire-and-forget submissions,
an "integrator" (for the lack of a better word for cleaning guy)
or "developer" to take up their posting is required.
But it often lacks one or more.
