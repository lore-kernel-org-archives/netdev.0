From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 00/51] DMA mask changes
Date: Fri, 27 Sep 2013 09:27:04 +0100
Message-ID: <20130927082703.GZ25647@n2100.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <CACna6rxkpYzdD8_Jfi22vA2suUa3k-JM65_gCySQpp4crVCoPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-ide@vger.kernel.org,
 "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 linux-samsung-soc@vger.kernel.org,
 Linux SCSI List <linux-scsi@vger.kernel.org>,
 e1000-devel@lists.sourceforge.net, b43-dev <b43-dev@lists.infradead.org>,
 linux-media@vger.kernel.org, devicetree@vger.kernel.org,
 dri-devel <dri-devel@lists.freedesktop.org>, linux-tegra@vger.kernel.org,
 linux-omap@vger.kernel.org,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 Network Development <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
 "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
 linux-crypto@vger.kernel.org, uclinux-dist-devel@black
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
Content-Disposition: inline
In-Reply-To: <CACna6rxkpYzdD8_Jfi22vA2suUa3k-JM65_gCySQpp4crVCoPg@mail.gmail.com>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

T24gVGh1LCBTZXAgMjYsIDIwMTMgYXQgMTA6MjM6MDhQTSArMDIwMCwgUmFmYcWCIE1pxYJlY2tp
IHdyb3RlOgo+IDIwMTMvOS8xOSBSdXNzZWxsIEtpbmcgLSBBUk0gTGludXggPGxpbnV4QGFybS5s
aW51eC5vcmcudWs+Ogo+ID4gVGhpcyBlbWFpbCBpcyBvbmx5IGJlaW5nIHNlbnQgdG8gdGhlIG1h
aWxpbmcgbGlzdHMgaW4gcXVlc3Rpb24sIG5vdCB0bwo+ID4gYW55b25lIHBlcnNvbmFsbHkuICBU
aGUgbGlzdCBvZiBpbmRpdmlkdWFscyBpcyBmYXIgdG8gZ3JlYXQgdG8gZG8gdGhhdC4KPiA+IEkn
bSBob3Bpbmcgbm8gbWFpbGluZyBsaXN0cyByZWplY3QgdGhlIHBhdGNoZXMgYmFzZWQgb24gdGhl
IG51bWJlciBvZgo+ID4gcmVjaXBpZW50cy4KPiAKPiBIdWgsIEkgdGhpbmsgaXQgd2FzIGVub3Vn
aCB0byBzZW5kIG9ubHkgMyBwYXRjaGVzIHRvIHRoZSBiNDMtZGV2QC4gTGlrZToKPiBbUEFUQ0gg
MDEvNTFdIERNQS1BUEk6IHByb3ZpZGUgYSBoZWxwZXIgdG8gc2V0IGJvdGggRE1BIGFuZCBjb2hl
cmVudCBETUEgbWFza3MKPiBbUEFUQ0ggMTQvNTFdIERNQS1BUEk6IG5ldDogYjQzOiAoLi4uKQo+
IFtQQVRDSCAxNS81MV0gRE1BLUFQSTogbmV0OiBiNDNsZWdhY3k6ICguLi4pCj4gOykKPiAKPiBJ
IGJlbGlldmUgSm9lIGhhcyBzb21lIG5pY2Ugc2NyaXB0IGZvciBkb2luZyBpdCB0aGF0IHdheS4g
V2hlbiBmaXhpbmcKPiBzb21lIGNvZGluZyBzdHlsZSAvIGZvcm1hdHRpbmcsIGhlIHNlbmRzIG9u
bHkgcmVsYXRlZCBwYXRjaGVzIHRvIHRoZQo+IGdpdmVuIE1MLgoKSWYgSSBkaWQgdGhhdCwgdGhl
biB0aGUgbWFpbGluZyBsaXN0cyB3b3VsZCBub3QgZ2V0IHRoZSBmaXJzdCBwYXRjaCwKYmVjYXVz
ZSBhbG1vc3Qgbm9uZSBvZiB0aGUgbGlzdHMgd291bGQgYmUgcmVmZXJyZWQgdG8gYnkgcGF0Y2gg
MS4KCk1vcmVvdmVyLCBwZW9wbGUgY29tcGxhaW4gd2hlbiB0aGV5IGRvbid0IGhhdmUgYWNjZXNz
IHRvIHRoZSBmdWxsCnBhdGNoIHNlcmllcyAtIHRoZXkgYXNzdW1lIHBhdGNoZXMgYXJlIG1pc3Np
bmcgZm9yIHNvbWUgcmVhc29uLCBhbmQKdGhleSBhc2sgZm9yIHRoZSByZXN0IG9mIHRoZSBzZXJp
ZXMuCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkFsc2Et
ZGV2ZWwgbWFpbGluZyBsaXN0CkFsc2EtZGV2ZWxAYWxzYS1wcm9qZWN0Lm9yZwpodHRwOi8vbWFp
bG1hbi5hbHNhLXByb2plY3Qub3JnL21haWxtYW4vbGlzdGluZm8vYWxzYS1kZXZlbAo=
