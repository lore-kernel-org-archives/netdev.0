From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v3] ip6_output: ensure flow saddr actually
	belongs to device
Date: Mon, 14 Nov 2016 17:54:06 +0100
Message-ID: <CAHmME9oztO74yyG2sP-6jWTqo8KzgZq=u-MDSx2S84R6WP4O+w@mail.gmail.com>
References: <27cccef1-06d9-74b3-5b8a-912850119a76@cumulusnetworks.com>
 <20161113232813.28926-1-Jason@zx2c4.com>
 <87012eb2-e52d-7058-4115-a4a3c70a7b4c@cumulusnetworks.com>
 <CAHmME9p6-mLSs84AwwfRXe8U3Z2sy6Dp9W9H0gKh0rcZuQAfZA@mail.gmail.com>
 <CAHmME9qC4xqGOwJnauXrJBDkAtmmuJ+kJKL6ufuU9_XWKNFdSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2622176316953255934=="
Cc: Netdev <netdev@vger.kernel.org>,
 Hannes Frederic Sowa <hannes@stressinduktion.org>,
 YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 LKML <linux-kernel@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>, David Miller <davem@davemloft.net>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <CAHmME9qC4xqGOwJnauXrJBDkAtmmuJ+kJKL6ufuU9_XWKNFdSA@mail.gmail.com>
List-Unsubscribe: <http://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <http://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

--===============2622176316953255934==
Content-Type: multipart/alternative; boundary=94eb2c0d90583a2dc8054145b0c8

--94eb2c0d90583a2dc8054145b0c8
Content-Type: text/plain; charset=UTF-8

On Nov 14, 2016 17:19, "David Ahern" <dsa@cumulusnetworks.com> wrote:
>
> LGTM
>
> Acked-by: David Ahern <dsa@cumulusnetworks.com>

Great.

@DaveM: can we get this in 4.9 and in stable?

Thanks,
Jason

--94eb2c0d90583a2dc8054145b0c8
Content-Type: text/html; charset=UTF-8

<p dir="ltr">On Nov 14, 2016 17:19, &quot;David Ahern&quot; &lt;<a href="mailto:dsa@cumulusnetworks.com">dsa@cumulusnetworks.com</a>&gt; wrote:<br>
&gt;<br>
&gt; LGTM<br>
&gt;<br>
&gt; Acked-by: David Ahern &lt;<a href="mailto:dsa@cumulusnetworks.com">dsa@cumulusnetworks.com</a>&gt;</p>
<p dir="ltr">Great.</p>
<p dir="ltr">@DaveM: can we get this in 4.9 and in stable?</p>
<p dir="ltr">Thanks,<br>
Jason</p>

--94eb2c0d90583a2dc8054145b0c8--

--===============2622176316953255934==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
WireGuard mailing list
WireGuard@lists.zx2c4.com
http://lists.zx2c4.com/mailman/listinfo/wireguard

--===============2622176316953255934==--
