From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: added sysctl for maximum number of addresses
Date: Thu, 15 Jan 2004 14:10:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115141016.15277a53.davem@redhat.com>
References: <20040115.213014.133549139.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0401151721380.16629-100000@netcore.fi>
	<20040116.003433.120676843.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, vnuorval@tcs.hut.fi, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040116.003433.120676843.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 16 Jan 2004 00:34:33 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> My point is the value becomes configurable.
> "16" is consistent with current behavior.
> I do not change the default value with this patch.
> 
> If you think it is too small, feel free to submit a patch to increase 
> the default value.

I agree with Yoshfuji-san, making it configurable and changing the default
are two different decisions to make and thus two different changes to make.

I will apply Yoshfuji's patch to make it configurable, and someone can submit
the change to make the default different and we can discuss that.
