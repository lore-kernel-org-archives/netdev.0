From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Re: [Patch] Kill off =?utf-8?Q?warning=3A_?=
	=?utf-8?B?4oCYaW5saW5l4oCZ?= is not at beginning of declaration
Date: Mon, 17 Jan 2011 14:13:59 -0200
Message-ID: <20110117161359.GA2885@vigoh>
References: <alpine.LNX.2.00.1101170000270.13377@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: alsa-devel@alsa-project.org, Mauro Carvalho Chehab <mchehab@redhat.com>,
	Takashi Iwai <tiwai@suse.de>, Frederic Weisbecker <fweisbec@gmail.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Jaroslav Kysela <perex@perex.cz>,
	Jens Axboe <jens.axboe@oracle.com>,
	Stephen Hemminger <shemminger@vyatta.com>, Andi Kleen <ak@linux.intel.com>,
	"Pekka Savola \(ipv6\)" <pekkas@netcore.fi>, x86@kernel.org,
	James Morris <jmorris@namei.org>, Ingo Molnar <mingo@redhat.com>,
	oprofile-list@lists.sf.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Mark Fasheh <mfasheh@suse.com>, Marcel Holtmann <marcel@holtmann.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Teigland <teigland@redhat.com>, Joel Becker <jlbec@evilplan.org>,
	Thomas Gleixner <tglx@linutronix.de>, linux-edac@vger.kernel.org,
	trivial@kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, Greg Kroah-Hartman
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <oprofile-list-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1101170000270.13377@swampdragon.chaosbits.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/oprofile-list>,
	<mailto:oprofile-list-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=oprofile-list>
List-Post: <mailto:oprofile-list@lists.sourceforge.net>
List-Help: <mailto:oprofile-list-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/oprofile-list>,
	<mailto:oprofile-list-request@lists.sourceforge.net?subject=subscribe>
Errors-To: oprofile-list-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

KiBKZXNwZXIgSnVobCA8ampAY2hhb3NiaXRzLm5ldD4gWzIwMTEtMDEtMTcgMDA6MDk6MzggKzAx
MDBdOgoKPiBGaXggYSBidW5jaCBvZiAKPiAJd2FybmluZzog4oCYaW5saW5l4oCZIGlzIG5vdCBh
dCBiZWdpbm5pbmcgb2YgZGVjbGFyYXRpb24KPiBtZXNzYWdlcyB3aGVuIGJ1aWxkaW5nIGEgJ21h
a2UgYWxseWVzY29uZmlnJyBrZXJuZWwgd2l0aCAtV2V4dHJhLgo+IAo+IFRoZXNlIHdhcm5pbmdz
IGFyZSB0cml2aWFsIHRvIGtpbGwsIHlldCByYXRoZXIgYW5ub3lpbmcgd2hlbiBidWlsZGluZyB3
aXRoIAo+IC1XZXh0cmEuCj4gVGhlIG1vcmUgd2UgY2FuIGN1dCBkb3duIG9uIHBvaW50bGVzcyBj
cmFwIGxpa2UgdGhpcyB0aGUgYmV0dGVyIChJTUhPKS4KPiAKPiBBIHByZXZpb3VzIHBhdGNoIHRv
IGRvIHRoaXMgZm9yIGEgJ2FsbG5vY29uZmlnJyBidWlsZCBoYXMgYWxyZWFkeSBiZWVuIAo+IG1l
cmdlZC4gVGhpcyBqdXN0IHRha2VzIHRoZSBjbGVhbnVwIGEgbGl0dGxlIGZ1cnRoZXIuCj4gCj4g
U2lnbmVkLW9mZi1ieTogSmVzcGVyIEp1aGwgPGpqQGNoYW9zYml0cy5uZXQ+Cj4gLS0tCj4gIGFy
Y2gveDg2L29wcm9maWxlL29wX21vZGVsX3A0LmMgfCAgICAyICstCj4gIGRyaXZlcnMvYmx1ZXRv
b3RoL2J0dXNiLmMgICAgICAgfCAgICA0ICsrLS0KPiAgZHJpdmVycy9jcHVpZGxlL3N5c2ZzLmMg
ICAgICAgICB8ICAgIDIgKy0KPiAgZHJpdmVycy9lZGFjL2k3MzAwX2VkYWMuYyAgICAgICB8ICAg
IDIgKy0KPiAgZnMvb2NmczIvZGlyLmMgICAgICAgICAgICAgICAgICB8ICAgIDIgKy0KPiAga2Vy
bmVsL3RyYWNlL3JpbmdfYnVmZmVyLmMgICAgICB8ICAgIDIgKy0KPiAgbmV0L2lwdjYvaW5ldDZf
aGFzaHRhYmxlcy5jICAgICB8ICAgIDIgKy0KPiAgbmV0L21hYzgwMjExL3R4LmMgICAgICAgICAg
ICAgICB8ICAgIDIgKy0KPiAgc291bmQvcGNpL2F1ODh4MC9hdTg4eDAuaCAgICAgICB8ICAgIDQg
KystLQo+ICBzb3VuZC9wY2kvYXU4OHgwL2F1ODh4MF9jb3JlLmMgIHwgICAgNCArKy0tCj4gIDEw
IGZpbGVzIGNoYW5nZWQsIDEzIGluc2VydGlvbnMoKyksIDEzIGRlbGV0aW9ucygtKQoKRm9yIGRy
aXZlcnMvYmx1ZXRvb3RoCgpBY2tlZC1ieTogR3VzdGF2byBGLiBQYWRvdmFuIDxwYWRvdmFuQHBy
b2Z1c2lvbi5tb2JpPgoKLS0gCkd1c3Rhdm8gRi4gUGFkb3ZhbgpodHRwOi8vcHJvZnVzaW9uLm1v
YmkKCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpQcm90ZWN0IFlvdXIgU2l0ZSBhbmQgQ3VzdG9tZXJz
IGZyb20gTWFsd2FyZSBBdHRhY2tzCkxlYXJuIGFib3V0IHZhcmlvdXMgbWFsd2FyZSB0YWN0aWNz
IGFuZCBob3cgdG8gYXZvaWQgdGhlbS4gVW5kZXJzdGFuZCAKbWFsd2FyZSB0aHJlYXRzLCB0aGUg
aW1wYWN0IHRoZXkgY2FuIGhhdmUgb24geW91ciBidXNpbmVzcywgYW5kIGhvdyB5b3UgCmNhbiBw
cm90ZWN0IHlvdXIgY29tcGFueSBhbmQgY3VzdG9tZXJzIGJ5IHVzaW5nIGNvZGUgc2lnbmluZy4K
aHR0cDovL3Auc2YubmV0L3NmdS9vcmFjbGUtc2ZkZXZubApfX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fXwpvcHJvZmlsZS1saXN0IG1haWxpbmcgbGlzdApvcHJv
ZmlsZS1saXN0QGxpc3RzLnNvdXJjZWZvcmdlLm5ldApodHRwczovL2xpc3RzLnNvdXJjZWZvcmdl
Lm5ldC9saXN0cy9saXN0aW5mby9vcHJvZmlsZS1saXN0Cg==
