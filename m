From: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Subject: Re: [RFC v2 2/2] proc connector: add a "get feature" op
Date: Thu, 20 Oct 2016 20:16:54 +0300
Message-ID: <123471476983814@web23g.yandex.ru>
References: <1476534370-4027-1-git-send-email-alban@kinvolk.io>
	<1476534370-4027-3-git-send-email-alban@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Iago Lopez Galeiras <iago-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Aaron Campbell <aaron-J6AcJDG0ZEwdnm+yROfE0A@public.gmane.org>,
	Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jesper Derehag <jderehag-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>,
	Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Dimitri John Ledkov <dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org"
	<containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1476534370-4027-3-git-send-email-alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

SGkgQWxiYW4KCjE1LjEwLjIwMTYsIDE1OjI4LCAiQWxiYW4gQ3JlcXV5IiA8YWxiYW4uY3JlcXV5
QGdtYWlsLmNvbT46Cj4gLXN0YXRpYyB2b2lkIGNuX3Byb2NfYWNrKGludCBlcnIsIGludCByY3Zk
X3NlcSwgaW50IHJjdmRfYWNrKQo+ICtzdGF0aWMgdm9pZCBjbl9wcm9jX2FjayhpbnQgZXJyLCB1
MTYgZmxhZ3MsIGludCByY3ZkX3NlcSwgaW50IHJjdmRfYWNrKQo+IMKgewo+IMKgwqDCoMKgwqDC
oMKgwqDCoHN0cnVjdCBjbl9tc2cgKm1zZzsKPiDCoMKgwqDCoMKgwqDCoMKgwqBzdHJ1Y3QgcHJv
Y19ldmVudCAqZXY7Cj4gwqDCoMKgwqDCoMKgwqDCoMKgX191OCBidWZmZXJbQ05fUFJPQ19NU0df
U0laRV0gX19hbGlnbmVkKDgpOwo+Cj4gLSBpZiAoYXRvbWljX3JlYWQoJnByb2NfZXZlbnRfbnVt
X2xpc3RlbmVycykgPCAxKQo+IC0gcmV0dXJuOwo+IC0KCldoeSBkbyB5b3UgcmVtb3ZlIG51bWJl
ciBvZiBsaXN0ZW5lcnMgY2hlY2s/Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGlu
dXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxt
YW4vbGlzdGluZm8vY29udGFpbmVycw==
