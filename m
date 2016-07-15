From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2 -next] wan/fsl_ucc_hdlc: info leak in uhdlc_ioctl()
Date: Fri, 15 Jul 2016 11:43:08 -0700 (PDT)
Message-ID: <20160715.114308.1901247006216834380.davem@davemloft.net>
References: <57876EE0.10603@bfs.de>
	<20160714111653.GA30452@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org, wharms@bfs.de,
 linuxppc-dev@lists.ozlabs.org, qiang.zhao@nxp.com
To: dan.carpenter@oracle.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20160714111653.GA30452@mwanda>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

RnJvbTogRGFuIENhcnBlbnRlciA8ZGFuLmNhcnBlbnRlckBvcmFjbGUuY29tPgpEYXRlOiBUaHUs
IDE0IEp1bCAyMDE2IDE0OjE2OjUzICswMzAwCgo+IFRoZXJlIGlzIGEgMiBieXRlIHN0cnVjdCB3
aG9sZSBhZnRlciBsaW5lLmxvb3BiYWNrIHNvIHdlIG5lZWQgdG8gY2xlYXIKPiB0aGF0IG91dCB0
byBhdm9pZCBkaXNjbG9zaW5nIHN0YWNrIGluZm9ybWF0aW9uLgo+IAo+IEZpeGVzOiBjMTliNmQy
NDZhMzUgKCdkcml2ZXJzL25ldDogc3VwcG9ydCBoZGxjIGZ1bmN0aW9uIGZvciBRRS1VQ0MnKQo+
IFNpZ25lZC1vZmYtYnk6IERhbiBDYXJwZW50ZXIgPGRhbi5jYXJwZW50ZXJAb3JhY2xlLmNvbT4K
PiAtLS0KPiB2MjogcmVtb3ZlIHRoZSBvdGhlciBpbml0aWFsaXphdGlvbiB0byB6ZXJvCgpBcHBs
aWVkLgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpMaW51
eHBwYy1kZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBsaXN0cy5vemxhYnMub3JnCmh0dHBz
Oi8vbGlzdHMub3psYWJzLm9yZy9saXN0aW5mby9saW51eHBwYy1kZXY=
