From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Mon, 16 Jul 2012 23:36:31 +0300
Message-ID: <CAJZOPZ+t+bw5u_nLZ21so7X5HeGYm41XFM_AHRihHK23M73a-Q@mail.gmail.com>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <50044F1D.6000703@hp.com>
 <20120716190611.GA1023@oc1711230544.ibm.com>
 <50046EB1.5040909@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4464545108669697078=="
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>,
 "amirv@mellanox.com" <amirv@mellanox.com>,
 "yevgenyp@mellanox.co.il" <yevgenyp@mellanox.co.il>,
 "klebers@linux.vnet.ibm.com" <klebers@linux.vnet.ibm.com>,
 Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
 "brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>,
 "ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "anton@samba.org" <anton@samba.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <50046EB1.5040909@hp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

--===============4464545108669697078==
Content-Type: multipart/alternative; boundary=bcaec555510099512804c4f86279

--bcaec555510099512804c4f86279
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Jul 16, 2012 at 10:42 PM, Rick Jones <rick.jones2@hp.com> wrote:

> I was thinking more along the lines of an additional comparison,
> explicitly using netperf TCP_RR or something like it, not just the packets
> per second from a bulk transfer test.
>

TCP_STREAM would be good to know here as well

Or.

--bcaec555510099512804c4f86279
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">On Mon, Jul 16, 2012 at 10:42 PM, Rick Jones <span dir=3D"=
ltr">&lt;<a href=3D"mailto:rick.jones2@hp.com" target=3D"_blank">rick.jones=
2@hp.com</a>&gt;</span> wrote:<br><div class=3D"gmail_quote"><blockquote cl=
ass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;p=
adding-left:1ex">
I was thinking more along the lines of an additional comparison, explicitly=
 using netperf TCP_RR or something like it, not just the packets per second=
 from a bulk transfer test.<span class=3D"HOEnZb"><font color=3D"#888888"><=
/font></span><br>
</blockquote></div><br>TCP_STREAM would be good to know here as well<br><br=
>Or.<br></div>

--bcaec555510099512804c4f86279--

--===============4464545108669697078==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============4464545108669697078==--
