From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] inet: Initialize per-netns inetpeer roots in net/ipv{4,
	6}/route.c
Date: Sun, 10 Jun 2012 13:14:16 +0800
Message-ID: <4FD42D28.4090200@cn.fujitsu.com>
References: <20120609.163202.516027044484907548.davem@davemloft.net>
	<20120610015832.GA9175@localhost> <20120610020801.GA9293@localhost>
	<20120609.190929.1165462964087672866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120609.190929.1165462964087672866.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

5LqOIDIwMTLlubQwNuaciDEw5pelIDEwOjA5LCBEYXZpZCBNaWxsZXIg5YaZ6YGTOgo+IEZyb206
IEZlbmdndWFuZyBXdSA8d2ZnQGxpbnV4LmludGVsLmNvbT4KPiBEYXRlOiBTdW4sIDEwIEp1biAy
MDEyIDEwOjA4OjAxICswODAwCj4gCj4+IEFuZCBpbiBhbm90aGVyIGNvbmZpZywgYW4gb2xkIGVy
cm9yIHN0aWxsIHRyaWdnZXJzOgo+Pgo+PiBuZXQvaXB2NC9pbmV0cGVlci5jOiBJbiBmdW5jdGlv
biDigJhmYW1pbHlfdG9fYmFzZeKAmToKPj4gbmV0L2lwdjQvaW5ldHBlZXIuYzozOTc6NTA6IGVy
cm9yOiDigJhzdHJ1Y3QgbmV04oCZIGhhcyBubyBtZW1iZXIgbmFtZWQg4oCYaXB2NuKAmQo+PiBu
ZXQvaXB2NC9pbmV0cGVlci5jOjM5ODoxOiB3YXJuaW5nOiBjb250cm9sIHJlYWNoZXMgZW5kIG9m
IG5vbi12b2lkIGZ1bmN0aW9uIFstV3JldHVybi10eXBlXQo+Pgo+PiBJJ20gYnVpbGRpbmcgdGhp
cyBwYXRjaCBvbiB0b3Agb2YgbmV0LW5leHQgbWFzdGVyLgo+IAo+IFdoYXQgYSBmdWNraW5nIG1l
c3MgR2FvIGNyZWF0ZWQsIEknbGwgZml4IHRoaXMuCgpPayxJIGFtIHNvcnJ5IGZvciB0aGVzZSB0
aGluZ3MuClBsZWFzZSBqdXN0IGtlZXAgY29vbCxJZiBJIGludHJvZHVjZSBzb21lIG1lc3NlcyxJ
IHdpbGwgZml4IGl0LgoKVGhhbmtzIQoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5s
aW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFp
bG1hbi9saXN0aW5mby9jb250YWluZXJz
