From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 3/3] x_tables: Factor out 16bit aligment ifname_compare()
Date: Mon, 12 Jan 2015 09:18:21 +0100
Message-ID: <54B3834D.6090602@nod.at>
References: <54B2EB81.5050604@nod.at>	<1421012376.9233.9.camel@perches.com>	<54B2EE4D.2080802@nod.at> <20150111.215050.458358747958425038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	john.fastabend@gmail.com, herbert@gondor.apana.org.au,
	vyasevic@redhat.com, jiri@resnulli.us, vfalico@gmail.com,
	therbert@google.com, edumazet@google.com, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, kuznet@ms2.inr.ac.ru, kadlec@blackhole.kfki.hu,
	kaber@trash.net, pablo@netfilter.org, kay@vrfy.org,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150111.215050.458358747958425038.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 12.01.2015 um 03:50 schrieb David Miller:
> From: Richard Weinberger <richard@nod.at>
> Date: Sun, 11 Jan 2015 22:42:37 +0100
> 
>> Joe, I really don't care. This is the least significant
>> patch of the series.
>> I'll no longer waste my time with that.
> 
> If you're not willing to fix stylistic issues now, then nobody should
> bother wasting their time on the high level issues of your patch.
> 
> Just fix these things now rather than being difficult, this is a part
> of patch review that everyone has to do, not just you.

I apologize, it was not my intention to be difficult.
Please note that the stylistic issue is not a warning produced
by checkpatch.pl. If you and netfilter folks now prefer bool
for such string compare functions I'll happily address this in
v2 of my series.

Thanks,
//richard
