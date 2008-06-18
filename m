From: "Rami Rosen" <ramirose@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipv6: minor cleanup in net/ipv6/tcp_ipv6.c [RESEND ].
Date: Wed, 18 Jun 2008 10:02:30 +0300
Message-ID: <eb3ff54b0806180002r3db43549h825ae1e307418223@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_47790_2089684.1213772550491"
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:16315 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759626AbYFRHCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 03:02:33 -0400
Received: by wf-out-1314.google.com with SMTP id 27so137777wfd.4
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 00:02:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_47790_2089684.1213772550491
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
Sorry, resending with  Signed-off-by:


 In net/ipv6/tcp_ipv6.c:

  - Remove unneeded tcp_v6_send_check() declaration.

Regards,
Rami Rosen

Signed-off-by: Rami Rosen <ramirose@gmail.com>




On Wed, Jun 18, 2008 at 9:01 AM, David Miller <davem@davemloft.net> wrote:
> From: "Rami Rosen" <ramirose@gmail.com>
> Date: Wed, 18 Jun 2008 08:54:52 +0300
>
>> Hi,
>> Certainly!
>>
>> In net/ipv6/tcp_ipv6.c:
>>
>>  - Remove unneeded tcp_v6_send_check() declaration.
>
> No signoff.
>

------=_Part_47790_2089684.1213772550491
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fhlkpysg0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L3RjcF9pcHY2LmMgYi9uZXQvaXB2Ni90Y3BfaXB2Ni5jCmlu
ZGV4IGRhZWZjMTguLjA5YmUwOWMgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L3RjcF9pcHY2LmMKKysr
IGIvbmV0L2lwdjYvdGNwX2lwdjYuYwpAQCAtNzAsOCArNzAsNiBAQAogCiBzdGF0aWMgdm9pZAl0
Y3BfdjZfc2VuZF9yZXNldChzdHJ1Y3Qgc29jayAqc2ssIHN0cnVjdCBza19idWZmICpza2IpOwog
c3RhdGljIHZvaWQJdGNwX3Y2X3JlcXNrX3NlbmRfYWNrKHN0cnVjdCBza19idWZmICpza2IsIHN0
cnVjdCByZXF1ZXN0X3NvY2sgKnJlcSk7Ci1zdGF0aWMgdm9pZAl0Y3BfdjZfc2VuZF9jaGVjayhz
dHJ1Y3Qgc29jayAqc2ssIGludCBsZW4sCi0JCQkJICBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKTsKIAog
c3RhdGljIGludAl0Y3BfdjZfZG9fcmN2KHN0cnVjdCBzb2NrICpzaywgc3RydWN0IHNrX2J1ZmYg
KnNrYik7CiAK
------=_Part_47790_2089684.1213772550491--
