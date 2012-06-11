From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] inet: Initialize per-netns inetpeer roots in
	net/ipv{4,6}/route.c
Date: Sun, 10 Jun 2012 20:03:18 -0700 (PDT)
Message-ID: <20120610.200318.590090545444949306.davem@davemloft.net>
References: <20120609.190929.1165462964087672866.davem@davemloft.net>
	<20120609.221801.2226110181753212240.davem@davemloft.net>
	<20120610101640.GA14476@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-7"
Content-Transfer-Encoding: base64
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120610101640.GA14476@localhost>
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
dW4gMjAxMiAxODoxNjo0MCArMDgwMA0KDQo+IG5ldC9pcHY0L2luZXRwZWVyLmM6NTg1Ojk6IGVy
cm9yOiBpbXBsaWNpdCBkZWNsYXJhdGlvbiBvZiBmdW5jdGlvbiChZmFtaWx5X3RvX2Jhc2WiIFst
V2Vycm9yPWltcGxpY2l0LWZ1bmN0aW9uLWRlY2xhcmF0aW9uXQ0KDQpUaGVyZSBhcmUgbm8gcmVm
ZXJlbmNlcyB0byBmYW1pbHlfdG9fYmFzZSBpbiB0aGUgbmV0LW5leHQgdHJlZS4NCg0KSWYgeW91
IG9ubHkgYXBwbGllZCB0aGUgcGF0Y2hlcyB5b3Ugd2VyZSBleHBsaWNpdGx5IENDOidkIG9uLA0K
dGhhdCdzIHRoZSBwcm9ibGVtLiAgVGhlcmUgd2VyZSBvdGhlciBjaGFuZ2VzIG1hZGUgaW4gdGhl
IG5ldC1uZXh0DQp0cmVlIGluLWJldHdlZW4gdGhhdCByZW1vdmUgdGhlIG90aGVyIHJlZmVyZW5j
ZXMgdG8gdGhhdCBmdW5jdGlvbi4NCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fCkNvbnRhaW5lcnMgbWFpbGluZyBsaXN0CkNvbnRhaW5lcnNAbGlzdHMubGlu
dXgtZm91bmRhdGlvbi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxt
YW4vbGlzdGluZm8vY29udGFpbmVycw==
