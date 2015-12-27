From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [Cocci] [PATCH v2] coccinelle: api: check for propagation of
 error from platform_get_irq
Date: Sun, 27 Dec 2015 17:24:02 +0100
Message-ID: <568010A2.3000902@users.sourceforge.net>
References: <1451157891-24881-1-git-send-email-Julia.Lawall@lip6.fr>
 <567EF188.7020203@cogentembedded.com>
 <alpine.DEB.2.02.1512262107340.2070@localhost6.localdomain6>
 <alpine.DEB.2.02.1512262123500.2070@localhost6.localdomain6>
 <567EF895.6080702@cogentembedded.com>
 <alpine.DEB.2.02.1512262156580.2070@localhost6.localdomain6>
 <567F9A29.50202@users.sourceforge.net>
 <alpine.DEB.2.02.1512271239460.2038@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
 Gilles Muller <Gilles.Muller@lip6.fr>, netdev@vger.kernel.org,
 Nicolas Palix <nicolas.palix@imag.fr>, kernel-janitors@vger.kernel.org,
 LKML <linux-kernel@vger.kernel.org>, dri-devel@lists.freedesktop.org,
 linux-spi@vger.kernel.org, Michal Marek <mmarek@suse.com>,
 linux-i2c@vger.kernel.org, Coccinelle <cocci@systeme.lip6.fr>,
 linux-media@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <alpine.DEB.2.02.1512271239460.2038@localhost6.localdomain6>
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

Pj4gaHR0cHM6Ly9jd2UubWl0cmUub3JnL2RhdGEvZGVmaW5pdGlvbnMvMjUyLmh0bWwKPiAKPiBU
aGUgdmFsdWUgaXMgbm90IHVuY2hlY2tlZC4KCldvdWxkIHlvdSBsaWtlIHRvIGV4cHJlc3MgYW55
IHN0cm9uZ2VyIHJlbGF0aW9uc2hpcCBiZXR3ZWVuCnRoZSBmdW5jdGlvbiBjYWxsIGV4YW1wbGUg
YW5kIHRoZSBvY2N1cnJlbmNlIG9mIGFuIGlmIHN0YXRlbWVudApieSB0aGUgZGlzY3Vzc2VkIFNt
UEwgc2NyaXB0PwoKCj4gSSBtYWRlIGEgc3BlY2lmaWMgcnVsZSBiZWNhdXNlIHRoZSBzcGVjaWZp
YyBwcm9ibGVtIGlzIHF1aXRlIGNvbW1vbi4KCkNhbiBpdCBiZWNvbWUgYWxzbyBpbnRlcmVzdGlu
ZyB0byBnZW5lcmFsaXNlIHRoaXMgc2VhcmNoIHBhdHRlcm4/CgpSZWdhcmRzLApNYXJrdXMKX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZHJpLWRldmVsIG1h
aWxpbmcgbGlzdApkcmktZGV2ZWxAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHA6Ly9saXN0cy5m
cmVlZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9kcmktZGV2ZWwK
