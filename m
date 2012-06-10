From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] inet: Initialize per-netns inetpeer roots in
	net/ipv{4,6}/route.c
Date: Sat, 09 Jun 2012 19:09:29 -0700 (PDT)
Message-ID: <20120609.190929.1165462964087672866.davem@davemloft.net>
References: <20120609.163202.516027044484907548.davem@davemloft.net>
	<20120610015832.GA9175@localhost> <20120610020801.GA9293@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-7"
Content-Transfer-Encoding: base64
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120610020801.GA9293@localhost>
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

RnJvbTogRmVuZ2d1YW5nIFd1IDx3ZmdAbGludXguaW50ZWwuY29tPg0KRGF0ZTogU3VuLCAxMCBK
dW4gMjAxMiAxMDowODowMSArMDgwMA0KDQo+IEFuZCBpbiBhbm90aGVyIGNvbmZpZywgYW4gb2xk
IGVycm9yIHN0aWxsIHRyaWdnZXJzOg0KPiANCj4gbmV0L2lwdjQvaW5ldHBlZXIuYzogSW4gZnVu
Y3Rpb24goWZhbWlseV90b19iYXNlojoNCj4gbmV0L2lwdjQvaW5ldHBlZXIuYzozOTc6NTA6IGVy
cm9yOiChc3RydWN0IG5ldKIgaGFzIG5vIG1lbWJlciBuYW1lZCChaXB2NqINCj4gbmV0L2lwdjQv
aW5ldHBlZXIuYzozOTg6MTogd2FybmluZzogY29udHJvbCByZWFjaGVzIGVuZCBvZiBub24tdm9p
ZCBmdW5jdGlvbiBbLVdyZXR1cm4tdHlwZV0NCj4gDQo+IEknbSBidWlsZGluZyB0aGlzIHBhdGNo
IG9uIHRvcCBvZiBuZXQtbmV4dCBtYXN0ZXIuDQoNCldoYXQgYSBmdWNraW5nIG1lc3MgR2FvIGNy
ZWF0ZWQsIEknbGwgZml4IHRoaXMuDQoNClRoYW5rcyBmb3IgdGhlIHJlcG9ydC4NCl9fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGlu
ZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0
cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
