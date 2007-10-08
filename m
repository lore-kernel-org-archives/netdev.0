From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 1/8][BNX2X] resubmit as attachments: add bnx2x to
 Kconfig and Makefile
Date: Mon, 08 Oct 2007 18:15:17 +0200
Message-ID: <470A5795.2000809@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary=------------030301080904080007070102
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4159 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752216AbXJHQOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 12:14:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030301080904080007070102
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit

Add bnx2x to Kconfig and Makefile



--------------030301080904080007070102
Content-Type: text/plain;
 name=0001-add-bnx2x-to-Kconfig-and-Makefile.txt
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename=0001-add-bnx2x-to-Kconfig-and-Makefile.txt

RnJvbSA5NGJmMzg1NTUwMzU2NTM0ZTZkZDQxY2U2MTg3OTYwOGE2M2VkOTcyIE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBFbGllemVyIFRhbWlyIDxlbGllemVydEBicm9hZGNv
bS5jb20+CkRhdGU6IE1vbiwgOCBPY3QgMjAwNyAxMTo0ODoxMCArMDIwMApTdWJqZWN0OiBb
UEFUQ0ggMS84XSBhZGQgYm54MnggdG8gS2NvbmZpZyBhbmQgTWFrZWZpbGUKClNpZ25lZC1v
ZmYtYnk6IEVsaWV6ZXIgVGFtaXIgPGVsaWV6ZXJ0QGJyb2FkY29tLmNvbT4KLS0tCiBkcml2
ZXJzL25ldC9LY29uZmlnICB8ICAgIDkgKysrKysrKysrCiBkcml2ZXJzL25ldC9NYWtlZmls
ZSB8ICAgIDEgKwogMiBmaWxlcyBjaGFuZ2VkLCAxMCBpbnNlcnRpb25zKCspLCAwIGRlbGV0
aW9ucygtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L0tjb25maWcgYi9kcml2ZXJzL25l
dC9LY29uZmlnCmluZGV4IDljNjM1YTIuLjFkNDRhNWUgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMv
bmV0L0tjb25maWcKKysrIGIvZHJpdmVycy9uZXQvS2NvbmZpZwpAQCAtMjYzMCw2ICsyNjMw
LDE1IEBAIGNvbmZpZyBURUhVVEkKIAloZWxwCiAJICBUZWh1dGkgTmV0d29ya3MgMTBHIEV0
aGVybmV0IE5JQwogCitjb25maWcgQk5YMlgKKwl0cmlzdGF0ZSAiQnJvYWRjb20gTmV0WHRy
ZW1lSUkgWEdiIHN1cHBvcnQiCisJZGVwZW5kcyBvbiBQQ0kKKwloZWxwCisJICBUaGlzIGRy
aXZlciBzdXBwb3J0cyBCcm9hZGNvbSBOZXRYdHJlbWVJSSAxMCBnaWdhYml0IEV0aGVybmV0
IGNhcmRzLgorCisJICBUbyBjb21waWxlIHRoaXMgZHJpdmVyIGFzIGEgbW9kdWxlLCBjaG9v
c2UgTSBoZXJlOiB0aGUgbW9kdWxlCisJICB3aWxsIGJlIGNhbGxlZCBibngyeC4gIFRoaXMg
aXMgcmVjb21tZW5kZWQuCisKIGVuZGlmICMgTkVUREVWXzEwMDAwCiAKIHNvdXJjZSAiZHJp
dmVycy9uZXQvdG9rZW5yaW5nL0tjb25maWciCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9N
YWtlZmlsZSBiL2RyaXZlcnMvbmV0L01ha2VmaWxlCmluZGV4IGQyZTBmMzUuLjJmMTFhMmMg
MTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L01ha2VmaWxlCisrKyBiL2RyaXZlcnMvbmV0L01h
a2VmaWxlCkBAIC02Myw2ICs2Myw3IEBAIG9iai0kKENPTkZJR19TVE5JQykgKz0gc3RuaWMu
byA4MzkwLm8KIG9iai0kKENPTkZJR19GRUFMTlgpICs9IGZlYWxueC5vCiBvYmotJChDT05G
SUdfVElHT04zKSArPSB0ZzMubwogb2JqLSQoQ09ORklHX0JOWDIpICs9IGJueDIubworb2Jq
LSQoQ09ORklHX0JOWDJYKSArPSBibngyeC5vCiBzcGlkZXJuZXQteSArPSBzcGlkZXJfbmV0
Lm8gc3BpZGVyX25ldF9ldGh0b29sLm8KIG9iai0kKENPTkZJR19TUElERVJfTkVUKSArPSBz
cGlkZXJuZXQubyBzdW5nZW1fcGh5Lm8KIG9iai0kKENPTkZJR19HRUxJQ19ORVQpICs9IHBz
M19nZWxpYy5vCi0tIAoxLjQuMgoK
--------------030301080904080007070102--

