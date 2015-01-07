From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Wed, 7 Jan 2015 17:21:09 +0000
Message-ID: <20150107172109.GR21820@casper.infradead.org>
References: <cover.1420594925.git.tgraf@suug.ch>
 <2b43c19c47e3702b370054f8fd11233e44179edf.1420594925.git.tgraf@suug.ch>
 <CA+mtBx_Jj-tUM1nbHd2fHb0-=QpK3tcQgA=smWmg=cB-fupdGg@mail.gmail.com>
 <20150107162129.GQ21820@casper.infradead.org>
 <CA+mtBx_A_M3+irq7w4nNCyPZBgM7ja+wfJT4w4Q0Yo6GMGYVgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+mtBx_A_M3+irq7w4nNCyPZBgM7ja+wfJT4w4Q0Yo6GMGYVgA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

T24gMDEvMDcvMTUgYXQgMDg6NTZhbSwgVG9tIEhlcmJlcnQgd3JvdGU6Cj4gT24gV2VkLCBKYW4g
NywgMjAxNSBhdCA4OjIxIEFNLCBUaG9tYXMgR3JhZiA8dGdyYWZAc3V1Zy5jaD4gd3JvdGU6Cj4g
PiBJZiB0aGUgVk5JIGlzIG5vdCBhbHJlYWR5IHVzZWQgZm9yIGFub3RoZXIgcHVycG9zZSwgeWVz
LiBUaGUgc29sdXRpb24KPiA+IGFzIHByb3Bvc2VkIGNhbiBiZSBpbnRlZ3JhdGVkIGludG8gZXhp
c3RpbmcgVlhMQU4gb3ZlcmxheXMgc2VwYXJhdGVkIGJ5Cj4gPiBWTkkuIEl0IGlzIGFsc28gY29t
cGF0aWJsZSB3aXRoIGhhcmR3YXJlIFZYTEFOIFZURVBzIHdoaWNoIGlnbm9yZSB0aGUKPiA+IHJl
c2VydmVkIGJpdHMgd2hpbGUgY29udGludWVpbmcgdG8gbWFpbnRhaW4gVk5JIHNlcGFyYXRpb24u
Cj4gCj4gSXQgc2VlbXMgbGlrZSBpdCBzaG91bGQgYmUgcmVsYXRpdmVseSBlYXN5IHRvIGdyb3Vw
IFZOSXMgdG9nZXRoZXIgdG8KPiBoYXZlIHRoZSBzYW1lIG1hcmsgd2l0aCB0aGUgY3VycmVudCB1
c2Ugb2YgVk5JLiBUaGUgd29ya3MgdXAgdG8gdGhlCj4gcG9pbnQgdGhhdCBhbGwgcGFja2V0cyBj
b3JyZXNwb25kaW5nIHRvIGEgc2luZ2xlIFZOSSBnZXQgdGhlIHNhbWUKPiBtYXJrLgoKVGhpcyBy
ZWFsbHkgZGVwZW5kcyBvbiB0aGUgbmV0d29yayBhcmNoaXRlY3R1cmUgYW5kIGFzc3VtZXMgdGhh
dCB5b3UKY2FuIHJlbWFwIHRoZSBWTklzIGluIHRoZSBlbnRpcmUgbmV0d29yay4gWW91IG1pZ2h0
IHdhbnQgdG8gcnVuIEwzCndpdGggZ3JvdXAgZGVmaW5pdGlvbnMgYWNyb3NzIG11bHRpcGxlIEwy
IFZOSSBzZWdtZW50cy4gQSBzZWNvbmQgaXNzdWUKaXMgdGhhdCBtYW55IGhhcmR3YXJlIFZYTEFO
IFZURVBzIGRvIFZOSSBiYXNlZCBsZWFybmluZyBhbmQgd2lsbCBydW4KaW50byBjYXBhY2l0eSBs
aW1pdHMuCgpJJ20gbm90IHNheWluZyBpdCdzIGltcG9zc2libGUgYnV0IGl0J3MgdmVyeSB0cmlj
a3kgdG8gaW50ZXJncmF0ZSBpZgp5b3UgY2FuJ3Qgc3RhcnQgZnJvbSBzY3JhdGNoLiBUaGUgd2hv
bGUgcG9pbnQgb2YgdGhpcyBpcyB0byBjb21lIHVwCndpdGggc29tZXRoaW5nIHRoYXQgaXMgcGFp
bmZ1bGx5IGVhc3kgdG8gdXNlIGFuZCBpbnRlZ3JhdGUgd2l0aG91dApyZXF1aXJpbmcgdG8gY2hh
bmdlIG11Y2guCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
CmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gu
b3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
