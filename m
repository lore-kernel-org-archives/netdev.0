From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [PATCH vringh 2/2] caif_virtio: Introduce caif over virtio
Date: Sat, 16 Feb 2013 09:48:48 +0100
Message-ID: <CAJK669ZATh8FojTGdFH_x7ovMvA2L7XFUratiptJmPFZPhv31g@mail.gmail.com>
References: <1360494273-27889-1-git-send-email-sjur.brandeland@stericsson.com>
	<1360494273-27889-3-git-send-email-sjur.brandeland@stericsson.com>
	<87vc9zfic8.fsf@rustcorp.com.au>
	<81C3A93C17462B4BBD7E272753C105792458EDD161@EXDCVYMBSTM005.EQ1STM.local>
	<87ehgklds9.fsf@rustcorp.com.au>
	<CAJK669YQ+x5zXSZA1FQHkRrcCt+SgZP-M_ea-Ey8ziGLhq9cqQ@mail.gmail.com>
	<87bobmjish.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Vikram ARV <vikram.arv@stericsson.com>,
	Dmitry TARNYAGIN <dmitry.tarnyagin@stericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linus Walleij <linus.walleij@linaro.org>, Ido Yariv <ido@wizery.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Erwan YVIN <erwan.yvin@stericsson.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87bobmjish.fsf@rustcorp.com.au>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

PiBTanVyIEJyw6ZuZGVsYW5kIDxzanVyYnJlbkBnbWFpbC5jb20+IHdyaXRlczoKPj4gSG93IGFi
b3V0IHN1cHBvcnRpbmcgc3RydWN0IHZyaW5naF9raW92IGFuZCBzdHJ1Y3Qga3ZlYyBhcyB3ZWxs
Pwo+PiBJIGN1cnJlbnRseSBnZXQgdGhlIGZvbGxvd2luZyBjb21wbGFpbnRzIHdpdGggbXkgVjIg
cGF0Y2gtc2V0Ogo+Pgo+PiBkcml2ZXJzL25ldC9jYWlmL2NhaWZfdmlydGlvLmM6NDg2OjI6IHdh
cm5pbmc6IHBhc3NpbmcgYXJndW1lbnQgMSBvZgo+PiDigJh2cmluZ2hfaW92X2luaXTigJkgZnJv
bSBpbmNvbXBhdGlibGUgcG9pbnRlciB0eXBlIFtlbmFibGVkIGJ5IGRlZmF1bHRdCj4KPiB2cmlu
Z2hfa2lvdl9pbml0KCk/ICBEaWQgSSBtaXNzIHNvbWV0aGluZyBlbHNlPwoKSSBnZXQgYSB3YXJu
aW5nIGZvciBteSB1c2VvZiB2cmluZ2hfaW92X2NsZWFudXAoKSBpbgphZGRpdGlvbiB0byB0aGUg
b25lIGFib3ZlLgoKSG93IGFib3V0IGFkZGluZyBraW92IHZhcmlhbnRzIG9mICB2cmluZ2hfaW92
X2NsZWFudXAoKQphbmQgdnJpbmdoX2lvdl9yZXNldCgpIGFzIHdlbGw/CgpUaGFua3MsClNqdXIK
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KVmlydHVhbGl6
YXRpb24gbWFpbGluZyBsaXN0ClZpcnR1YWxpemF0aW9uQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24u
b3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3Zp
cnR1YWxpemF0aW9u
