From: David Brownell <david-b@pacbell.net>
Subject: Re: PATCH: usbnet: doc updates
Date: Sun, 5 Sep 2010 21:48:01 -0700 (PDT)
Message-ID: <414445.95907.qm@web180304.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-843927087-1283748481=:95907"
Cc: netdev@vger.kernel.org, linux@rainbow-software.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n1-vm1.bullet.mail.gq1.yahoo.com ([67.195.23.153]:40754 "HELO
	n1-vm1.bullet.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751119Ab0IFEsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 00:48:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0-843927087-1283748481=:95907
Content-Type: text/plain; charset=us-ascii

--- On Sun, 9/5/10, David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Subject: Re: PATCH: usbnet: doc updates
> To: david-b@pacbell.net
> Cc: netdev@vger.kernel.org, linux@rainbow-software.org
> Date: Sunday, September 5, 2010, 5:12 PM
> From: David Brownell <david-b@pacbell.net>
> Date: Sun, 5 Sep 2010 17:06:10 -0700 (PDT)
> 
> > Apologies in advance for sending this as an
> > attachment, but I think it's less likely to get
> > angled (except quoted-printable?) this way.
> 
> Well, patchwork didn't grok it at all, and this means your
> patch is a
> lot more work for me.

If I had my normal mail access, I'd send this
patch inline; but I don't.


> 
> Actually looking at the patch, the comment formatting is
> not all
> that pretty:


I guess you don't like

    /*
     preformatted text ...
    */

as a comment style.  Fixed in the attached.
--0-843927087-1283748481=:95907
Content-Type: application/octet-stream; name=rxfix
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="rxfix"

U2lnbmVkLW9mZi1ieTogRGF2aWQgQnJvd25lbGwgPGRicm93bmVsbEB1c2Vy
cy5zb3VyY2Vmb3JnZS5uZXQ+ClN1YmplY3Q6IHVzYm5ldDogZG9jIHVwZGF0
ZXMKClByb3ZpZGUgbW9yZSBkb2N1bWVudGF0aW9uIGFib3V0IHRoZSByeF9m
aXh1cCgpIGNhbGxpbmcgY29udmVudGlvbiwKdG8gaGVscCByZWR1Y2Ugc29t
ZSByZWNlbnRseS1vYnNlcnZlZCBjb25mdXNpb24uCgpBbHNvIHN1bW1hcml6
ZSB0aGUgZXF1aXZhbGVuY2Ugb2YgVVNCIGFuZCBuZXR3b3JrIFRYL1JYIHF1
ZXVlcywgdG8KaGVscCBoaWdobGlnaHQgdGhlIHJvbGVzIG9mIHRoZSBmaXh1
cCgpIHJvdXRpbmVzIHdpdGggbGluayBwcm90b2NvbHMKdXNpbmcgdGhlIENQ
VS1pbnRlbnNpdmUgcGFja2V0IGJhdGNoaW5nIG1vZGVscy4KClNpZ25lZC1v
ZmYtYnk6IERhdmlkIEJyb3duZWxsIDxkYnJvd25lbGxAdXNlcnMuc291cmNl
Zm9yZ2UubmV0PgotLS0KCgogaW5jbHVkZS9saW51eC91c2IvdXNibmV0Lmgg
fCAgIDMxICsrKysrKysrKysrKysrKysrKysrKysrKysrKysrLS0KIDEgZmls
ZSBjaGFuZ2VkLCAyOSBpbnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQoK
LS0tIGEvaW5jbHVkZS9saW51eC91c2IvdXNibmV0LmgKKysrIGIvaW5jbHVk
ZS9saW51eC91c2IvdXNibmV0LmgKQEAgLTIyLDggKzIyLDIyIEBACiAjaWZu
ZGVmCV9fTElOVVhfVVNCX1VTQk5FVF9ICiAjZGVmaW5lCV9fTElOVVhfVVNC
X1VTQk5FVF9ICiAKLS8qIGludGVyZmFjZSBmcm9tIHVzYm5ldCBjb3JlIHRv
IGVhY2ggVVNCIG5ldHdvcmtpbmcgbGluayB3ZSBoYW5kbGUgKi8KKy8qKiBp
bnRlcmZhY2UgZnJvbSB1c2JuZXQgY29yZSB0byBlYWNoIFVTQiBuZXR3b3Jr
aW5nIGxpbmsgd2UgaGFuZGxlLgorICoKKyAqIE5vdGUgdGhhdCB0aGUgZGVz
aWduIGNlbnRlciBmb3IgdXNibmV0IGhhcyBvbmUgSUVFRSBwYWNrZXQgcGVy
IFVSQiwKKyAqIGFuZCBtYXBzIG5ldHdvcmsgVFggYW5kIFJYIHF1ZXVlcyBk
aXJlY3RseSB0byB0aGUKKyAqIFVTQiBoYXJkd2FyZSBUWC9SWCBxdWV1ZXMs
IG1pbmltaXppbmcgc29mdHdhcmUgYW5kIGhhcmR3YXJlIG92ZXJoZWFkLgor
ICogU29tZSBsaW5rIHByb3RvY29scyAobGlrZSBSTkRJUyBhbmQgQ0RDIE5D
TSkgcHJvbW90ZSAgbGVzcyBlZmZpY2llbnQKKyAqIGRlc2lnbnMgd2hpY2gg
aW52b2x2ZSBiYXRjaGluZyBtdWx0aXBsZSBJRUVFIHBhY2tldHMgaW4gZWFj
aCBVUkIsCisgKiB3aXRoIGluY3JlYXNlZCBUWCBvdmVyaGVhZCB0byBjb3B5
IElFRUUgcGFja2V0cyBpbnRvIFRYIFVSQnMnIGRhdGEKKyAqIGJ1ZmZlcnMg
aW4gdHhfZml4dXAoKSByb3V0aW5lcywgcGx1cyB1bmJhdGNoaW5nIHdvcmsg
aW4gcnhfZml4dXAoKSB0b28uCisgKiBTb21ldGltZXMgdGhlIFRYIG92ZXJo
ZWFkIGNhbiBiZSBtaW5pbWl6ZWQgb24gTGludXggYnkgbm90IGJhdGNoaW5n
LCBidXQKKyAqIHRoaXMgdXN1YWxseSB3b24ndCB3b3JrIGZvciBSWCBiZWNh
dXNlIG9mIHRoZSBuZWVkIHRvIGludGVyb3BlcmF0ZSB3aXRoCisgKiBpbXBs
ZW1lbnRhdGlvbnMgd2hpY2ggYmF0Y2ggb24gVFguCisgKi8KKwogc3RydWN0
IHVzYm5ldCB7CisKIAkvKiBob3VzZWtlZXBpbmcgKi8KIAlzdHJ1Y3QgdXNi
X2RldmljZQkqdWRldjsKIAlzdHJ1Y3QgdXNiX2ludGVyZmFjZQkqaW50ZjsK
QEAgLTExMyw3ICsxMjcsMjAgQEAgc3RydWN0IGRyaXZlcl9pbmZvIHsKIAkv
KiBsaW5rIHJlc2V0IGhhbmRsaW5nLCBjYWxsZWQgZnJvbSBkZWZlcl9rZXZl
bnQgKi8KIAlpbnQJKCpsaW5rX3Jlc2V0KShzdHJ1Y3QgdXNibmV0ICopOwog
Ci0JLyogZml4dXAgcnggcGFja2V0IChzdHJpcCBmcmFtaW5nKSAqLworCS8q
IGZpeHVwIHJ4IHBhY2tldCAoIGJ5IHN0cmlwcGluZyBmcmFtaW5nIGZyb20g
VVJCL1NLQi4KKwkgKgorCSAqIElmIFNLQiBiYXRjaGVzIG9uZSBvciBtb3Jl
IHBhY2tldHMsIHBhc3MgYWxsIGJ1dCBvbmUgb2YgdGhlbQorCSAqIHVwIHRo
ZSBzdGFjayAoY2xvbmUgU0tCIGFuZCBmaXh1cCBlYWNoIGNsb25lIGJlZm9y
ZSBuZXRpZl9yeCkpLgorCSAqCisKKwkgKiBXaGVuIHlvdSBsZWF2ZSBvbmUg
cGFja2V0IGluIFNLQiAoaW50ZW5kZWQgdXNhZ2UpLCByZXR1cm4KKwkgKiBu
b256ZXJvIGFuZCBlbnN1cmUgc2tiLWxlbiBpcyBub256ZXJvLiAgdGhlIHBh
Y2tldCB3aWxsIGJlCisJICogcGFzc2VkIHVwIHRoZSBuZXR3b3JrIHN0YWNr
IGFuZCBhY2NvdW50ZWQgcHJvcGVybHkuCisJICoKKwkgKiByZXR1cm4gemVy
byB0byBpbmRpY2F0ZSBlcnJvcnMgc3VjaCBhcyB0b28gbXVjaCBoZWFkZXIg
b3IKKwkgKiBkYXRhLCBvciBhIGJhZCBjaGVja3N1bTsgdGhlIHBhY2tldCB3
aWxsIGJlIGRyb3BwZWQKKwkgKiBhbmQgYWNjb3VudGVkIGFzIGFuIGVycm9y
LgorCSovCiAJaW50CSgqcnhfZml4dXApKHN0cnVjdCB1c2JuZXQgKmRldiwg
c3RydWN0IHNrX2J1ZmYgKnNrYik7CiAKIAkvKiBmaXh1cCB0eCBwYWNrZXQg
KGFkZCBmcmFtaW5nKSAqLwo=

--0-843927087-1283748481=:95907--

