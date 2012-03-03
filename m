From: "Kiss Gabor (Bitman)" <kissg@ssg.ki.iif.hu>
Subject: Patch to ip(8) manpage
Date: Sat, 3 Mar 2012 10:18:01 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1203031007180.22132@bakacsin.ki.iif.hu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="113323998-838828178-1330766281=:22132"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from strudel.ki.iif.hu ([193.6.222.244]:59619 "EHLO
	strudel.ki.iif.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855Ab2CCJZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 04:25:54 -0500
Received: from cirkusz.lvs.iif.hu (cirkusz.lvs.iif.hu [193.225.14.182])
	by strudel.ki.iif.hu (Postfix) with ESMTP id EA610167
	for <netdev@vger.kernel.org>; Sat,  3 Mar 2012 10:18:03 +0100 (CET)
Received: from strudel.ki.iif.hu ([IPv6:::ffff:193.6.222.244])
	by cirkusz.lvs.iif.hu (cirkusz.lvs.iif.hu [::ffff:193.225.14.72]) (amavisd-new, port 10024)
	with ESMTP id xuQKiLmZh4ws for <netdev@vger.kernel.org>;
	Sat,  3 Mar 2012 10:18:01 +0100 (CET)
Received: from bakacsin.ki.iif.hu (bakacsin.ki.iif.hu [193.6.222.47])
	by strudel.ki.iif.hu (Postfix) with ESMTP id ACDCC166
	for <netdev@vger.kernel.org>; Sat,  3 Mar 2012 10:18:01 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by bakacsin.ki.iif.hu (Postfix) with ESMTP id 05CBF9138C4
	for <netdev@vger.kernel.org>; Sat,  3 Mar 2012 10:18:01 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--113323998-838828178-1330766281=:22132
Content-Type: TEXT/PLAIN; charset=US-ASCII

Dear folks,

For a while I did not understand why I get
"RTNETLINK answers: Numerical result out of range"
message when adding more addresses to an interface.

The attached patch may help some peoples to avoid wasting
time with investigating this strange error. :-)

Regards

Gabor
--113323998-838828178-1330766281=:22132
Content-Type: TEXT/x-diff; name=ip.8-labellength.patch
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.DEB.2.00.1203031018000.22132@bakacsin.ki.iif.hu>
Content-Description: 
Content-Disposition: attachment; filename=ip.8-labellength.patch

LS0tIGlwLjgub3JpZwkyMDEyLTAzLTAzIDA5OjU2OjAzLjUwNTUxODc3OCAr
MDEwMA0KKysrIGlwLjgJMjAxMi0wMy0wMyAxMDowNjoxNy42ODU1MTk5NjEg
KzAxMDANCkBAIC0xMTAzLDYgKzExMDMsMTMgQEANCiB0aGlzIHN0cmluZyBt
dXN0IGNvaW5jaWRlIHdpdGggdGhlIG5hbWUgb2YgdGhlIGRldmljZSBvciBt
dXN0IGJlIHByZWZpeGVkDQogd2l0aCB0aGUgZGV2aWNlIG5hbWUgZm9sbG93
ZWQgYnkgY29sb24uDQogDQorTm90ZTogDQorLkkgTkFNRQ0KK211c3QgYmUg
c2hvcnRlciB0aGFuDQorLkJSIElGX05BTUVTSVpFDQorKHVzdWFsbHkgMTYp
IGNoYXJhY3RlcnMuIFRoYXQgaXMgZGVmaW5lZCBpbg0KKy5CUiAiL3Vzci9p
bmNsdWRlL25ldC9pZi5oIiAuDQorDQogLlRQDQogLkJJIHNjb3BlICIgU0NP
UEVfVkFMVUUiDQogdGhlIHNjb3BlIG9mIHRoZSBhcmVhIHdoZXJlIHRoaXMg
YWRkcmVzcyBpcyB2YWxpZC4NCg==

--113323998-838828178-1330766281=:22132--
