From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [Patch ] net: doc: cleanup
 Documentation/networking/scaling.txt
Date: Fri, 3 Feb 2012 22:28:04 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1202032227260.25026@pobox.suse.cz>
References: <4EDF768F.1000500@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Randy Dunlap (maintainer:DOCUMENTATION)" <rdunlap@xenotime.net>,
	David Miller <davem@davemloft.net>, willemb@google.com,
	benjamin.poirier@gmail.com, linux-doc@vger.kernel.org,
	Network Developer Mailing List <netdev@vger.kernel.org>,
	therbert@google.com
To: Shan Wei <shanwei88@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4EDF768F.1000500@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Dec 2011, Shan Wei wrote:

>=20
> 1) Fix some typos.
> 2) Change mode of the punctuation from full to half, eg.=A1=AF,=A1=B0=
 .
>    So that the punctuation can be read at console.
>=20
> Signed-off-by: Shan Wei<shanwei88@gmail.com>
> ---
> I feel uncertain when reading following contents that no variable
> in rps_dev_flow_table or softnet_data records the length of=20
> the current backlog. Just last_qtail variable pointers the tail of th=
e backlog.
>=20
> "The counter in rps_dev_flow_table values records the length of the c=
urrent
>  CPU's backlog when a packet in this flow was last enqueued. "
>=20
> If missing something, please correct me.

To a minimum, the patch is corrupted. Please fix your mail client and=20
resend.

--=20
Jiri Kosina
SUSE Labs
