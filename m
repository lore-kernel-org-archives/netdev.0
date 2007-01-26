From: David Hollis <dhollis@davehollis.com>
Subject: Re: [USBNET] ASIX: Add IO-DATA ETG-US2 Support.
Date: Fri, 26 Jan 2007 11:51:10 -0500
Message-ID: <1169830270.3695.11.camel@dhollis-lnx.sunera.com>
References: <20070126.225738.24355200.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	linux-usb-devel@lists.sourceforge.net, Greg KH <greg@kroah.com>
To: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?= <yoshfuji@linux-ipv6.org>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-reply-to: <20070126.225738.24355200.yoshfuji@linux-ipv6.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

T24gRnJpLCAyMDA3LTAxLTI2IGF0IDIyOjU3ICswOTAwLCBZT1NISUZVSkkgSGlkZWFraSAvIOWQ
ieiXpOiLseaYjiB3cm90ZToKPiBTaWduZWQtb2ZmLWJ5OiBZT1NISUZVSkkgSGlkZWFraSA8eW9z
aGZ1amlAbGludXgtaXB2Ni5vcmc+CgpBY2tlZC1ieTogRGF2aWQgSG9sbGlzIDxkaG9sbGlzQGRh
dmVob2xsaXMuY29tPgoKCj4gLS0tCj4gIGRyaXZlcnMvdXNiL25ldC9hc2l4LmMgfCAgICA0ICsr
KysKPiAgMSBmaWxlcyBjaGFuZ2VkLCA0IGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0pCj4g
Cj4gZGlmZiAtLWdpdCBhL2RyaXZlcnMvdXNiL25ldC9hc2l4LmMgYi9kcml2ZXJzL3VzYi9uZXQv
YXNpeC5jCj4gaW5kZXggODk2NDQ5Zi4uNDIwNmRmMiAxMDA2NDQKPiAtLS0gYS9kcml2ZXJzL3Vz
Yi9uZXQvYXNpeC5jCj4gKysrIGIvZHJpdmVycy91c2IvbmV0L2FzaXguYwo+IEBAIC0xNDQ5LDYg
KzE0NDksMTAgQEAgc3RhdGljIGNvbnN0IHN0cnVjdCB1c2JfZGV2aWNlX2lkCXByb2R1Y3RzIFtd
ID0gewo+ICAJLy8gTGlua3N5cyBVU0IxMDAwCj4gIAlVU0JfREVWSUNFICgweDE3MzcsIDB4MDAz
OSksCj4gIAkuZHJpdmVyX2luZm8gPSAodW5zaWduZWQgbG9uZykgJmF4ODgxNzhfaW5mbywKPiAr
fSwgewo+ICsJLy8gSU8tREFUQSBFVEctVVMyCj4gKwlVU0JfREVWSUNFICgweDA0YmIsIDB4MDkz
MCksCj4gKwkuZHJpdmVyX2luZm8gPSAodW5zaWduZWQgbG9uZykgJmF4ODgxNzhfaW5mbywKPiAg
fSwKPiAgCXsgfSwJCS8vIEVORAo+ICB9OwotLSAKRGF2aWQgSG9sbGlzIDxkaG9sbGlzQGRhdmVo
b2xsaXMuY29tPgoKCgotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tClRha2UgU3VydmV5cy4gRWFybiBDYXNoLiBJ
bmZsdWVuY2UgdGhlIEZ1dHVyZSBvZiBJVApKb2luIFNvdXJjZUZvcmdlLm5ldCdzIFRlY2hzYXkg
cGFuZWwgYW5kIHlvdSdsbCBnZXQgdGhlIGNoYW5jZSB0byBzaGFyZSB5b3VyCm9waW5pb25zIG9u
IElUICYgYnVzaW5lc3MgdG9waWNzIHRocm91Z2ggYnJpZWYgc3VydmV5cyAtIGFuZCBlYXJuIGNh
c2gKaHR0cDovL3d3dy50ZWNoc2F5LmNvbS9kZWZhdWx0LnBocD9wYWdlPWpvaW4ucGhwJnA9c291
cmNlZm9yZ2UmQ0lEPURFVkRFVgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fXwpsaW51eC11c2ItZGV2ZWxAbGlzdHMuc291cmNlZm9yZ2UubmV0ClRvIHVuc3Vi
c2NyaWJlLCB1c2UgdGhlIGxhc3QgZm9ybSBmaWVsZCBhdDoKaHR0cHM6Ly9saXN0cy5zb3VyY2Vm
b3JnZS5uZXQvbGlzdHMvbGlzdGluZm8vbGludXgtdXNiLWRldmVsCg==
