From: "Rami Rosen" <ramirose@gmail.com>
Subject: Re: [PATCH net-2.6 2/2] ipv6: minor cleanup in net/ipv6/tcp_ipv6.c
Date: Mon, 16 Jun 2008 12:51:35 +0300
Message-ID: <eb3ff54b0806160251w75b1818dh521f2c8cd8ca0c79@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_38138_328045.1213609895244"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "=?BIG5?B?WU9TSElGVUpJIEhpZGVha2kgLyCmTsPDrV6p+g==?="
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:44723 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756967AbYFPJvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 05:51:35 -0400
Received: by wf-out-1314.google.com with SMTP id 27so5141366wfd.4
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2008 02:51:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_38138_328045.1213609895244
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
Fixing signed-off by line also in this second patch,
Rami

On Mon, Jun 16, 2008 at 12:41 PM, YOSHIFUJI Hideaki / 吉藤英明
<yoshfuji@linux-ipv6.org> wrote:
> In article <eb3ff54b0806160207r473055c3y329b6ec66b902572@mail.gmail.com> (at Mon, 16 Jun 2008 12:07:31 +0300), "Rami Rosen" <ramirose@gmail.com> says:
>
>> Signed-off-by: Rami Rosen <ramirose@gmail.com>
>
> Would you please fix signed-off-by line in the patches?
>
> --yoshfuji
>

------=_Part_38138_328045.1213609895244
Content-Type: text/plain; name=patch2.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fhivwsgv0
Content-Disposition: attachment; filename=patch2.txt

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L3RjcF9pcHY2LmMgYi9uZXQvaXB2Ni90Y3BfaXB2Ni5jCmlu
ZGV4IGNiNDY3NDkuLjBhNDM3ZTAgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L3RjcF9pcHY2LmMKKysr
IGIvbmV0L2lwdjYvdGNwX2lwdjYuYwpAQCAtNzIsOCArNzIsNiBAQAogCiBzdGF0aWMgdm9pZAl0
Y3BfdjZfc2VuZF9yZXNldChzdHJ1Y3Qgc29jayAqc2ssIHN0cnVjdCBza19idWZmICpza2IpOwog
c3RhdGljIHZvaWQJdGNwX3Y2X3JlcXNrX3NlbmRfYWNrKHN0cnVjdCBza19idWZmICpza2IsIHN0
cnVjdCByZXF1ZXN0X3NvY2sgKnJlcSk7Ci1zdGF0aWMgdm9pZAl0Y3BfdjZfc2VuZF9jaGVjayhz
dHJ1Y3Qgc29jayAqc2ssIGludCBsZW4sCi0JCQkJICBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKTsKIAog
c3RhdGljIGludAl0Y3BfdjZfZG9fcmN2KHN0cnVjdCBzb2NrICpzaywgc3RydWN0IHNrX2J1ZmYg
KnNrYik7CiAKQEAgLTExMDEsOSArMTA5OSw2IEBAIHN0YXRpYyB2b2lkIHRjcF92Nl9zZW5kX2Fj
ayhzdHJ1Y3QgdGNwX3RpbWV3YWl0X3NvY2sgKnR3LAogI2lmZGVmIENPTkZJR19UQ1BfTUQ1U0lH
CiAJc3RydWN0IHRjcF9tZDVzaWdfa2V5ICprZXk7CiAJc3RydWN0IHRjcF9tZDVzaWdfa2V5IHR3
X2tleTsKLSNlbmRpZgotCi0jaWZkZWYgQ09ORklHX1RDUF9NRDVTSUcKIAlpZiAoIXR3ICYmIHNr
Yi0+c2spIHsKIAkJa2V5ID0gdGNwX3Y2X21kNV9kb19sb29rdXAoc2tiLT5zaywgJmlwdjZfaGRy
KHNrYiktPmRhZGRyKTsKIAl9IGVsc2UgaWYgKHR3ICYmIHR3LT50d19tZDVfa2V5bGVuKSB7Cgo=

------=_Part_38138_328045.1213609895244--
