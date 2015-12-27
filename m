From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH v2] coccinelle: api: check for propagation of error from
 platform_get_irq
Date: Sun, 27 Dec 2015 07:13:48 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1512270709420.2038@localhost6.localdomain6>
References: <1451157891-24881-1-git-send-email-Julia.Lawall@lip6.fr>
 <567EF188.7020203@cogentembedded.com>
 <alpine.DEB.2.02.1512262107340.2070@localhost6.localdomain6>
 <alpine.DEB.2.02.1512262123500.2070@localhost6.localdomain6>
 <567EF895.6080702@cogentembedded.com>
 <alpine.DEB.2.02.1512262156580.2070@localhost6.localdomain6>
 <567F141C.8010000@cogentembedded.com>
 <alpine.DEB.2.02.1512262330430.2070@localhost6.localdomain6>
 <567F166B.7030208@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: kernel-janitors@vger.kernel.org, Gilles Muller <Gilles.Muller@lip6.fr>,
 netdev@vger.kernel.org, Nicolas Palix <nicolas.palix@imag.fr>,
 linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-spi@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>,
 Michal Marek <mmarek@suse.com>, linux-i2c@vger.kernel.org,
 cocci@systeme.lip6.fr, linux-media@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <567F166B.7030208@cogentembedded.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

PiAgICBXZWxsLCBsb29raW5nIGFnYWluLCB0aGUgcGF0Y2ggc2hvdWxkIGJlIGdvb2QuIEkganVz
dCB0aG91Z2h0IGl0cyBnb2FsIHdhcwo+IHRvIGZpeCB0aGUgY29kZSBhcyB3ZWxsLi4uCgpJIGNv
dWxkIGRvIHRoYXQgZm9yIHRoZSBpcnEgPCAwIGNhc2UsIGJ1dCBJIHRoaW5rIHRoYXQgaW4gdGhh
dCBjYXNlLCBrYnVpbGQKd2lsbCBvbmx5IHJ1biB0aGUgcGF0Y2ggdmVyc2lvbiwgYW5kIHRoZSA8
PSBjYXNlcyB3aWxsIG5vdCBiZSByZXBvcnRlZCBvbi4KSSBkb24ndCBoYXZlIGEgZ2VuZXJhbCBm
aXggZm9yIHRoZSA8PSAwLiAgSXMgaXQgZXZlbiBjb3JyZWN0IHRvIGhhdmUgPCBpbgpzb21lIGNh
c2VzIGFuZCA8PSBpbiBvdGhlcnM/CgpqdWxpYQpfX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fXwpkcmktZGV2ZWwgbWFpbGluZyBsaXN0CmRyaS1kZXZlbEBsaXN0
cy5mcmVlZGVza3RvcC5vcmcKaHR0cDovL2xpc3RzLmZyZWVkZXNrdG9wLm9yZy9tYWlsbWFuL2xp
c3RpbmZvL2RyaS1kZXZlbAo=
