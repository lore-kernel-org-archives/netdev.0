From: Oskar Andreasson <blueflux@koffein.net>
Subject: [PATCH] proc.txt document fix of error_burst and error_cost
Date: Thu, 7 Nov 2002 18:00:35 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0211071755470.5001-200000@laptop1.agatha>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463810815-1804465649-1036688435=:5001"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
   "Alexey N. Kuznetsov" <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1463810815-1804465649-1036688435=:5001
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi,

Jamal asked me to direct this patch to you both. 

In short, the patch fixes some bad documentation of the error_burst and 
error_cost sysctl's in Documentation/filesystems/proc.txt. I have tried to 
retain the old style of the document as much as possible, as well as 
choice of words. 

The patch should apply against both 2.4.19 and 2.5.45 without problems.

Is there anything wrong with it, or may it be included? Suggestions? 

-- 
----
Oskar Andreasson
http://www.frozentux.net
http://iptables-tutorial.frozentux.net
http://ipsysctl-tutorial.frozentux.net
mailto:blueflux@koffein.net

---1463810815-1804465649-1036688435=:5001
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="2.4.19.docs.fs.proc.txt-2.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0211071800350.5001@laptop1.agatha>
Content-Description: 
Content-Disposition: attachment; filename="2.4.19.docs.fs.proc.txt-2.patch"

ZGlmZiAtdXIgbGludXgtMi40LjE5L0RvY3VtZW50YXRpb24vZmlsZXN5c3Rl
bXMvcHJvYy50eHQgbGludXgtMi40LjE5Lm5ldy9Eb2N1bWVudGF0aW9uL2Zp
bGVzeXN0ZW1zL3Byb2MudHh0DQotLS0gbGludXgtMi40LjE5L0RvY3VtZW50
YXRpb24vZmlsZXN5c3RlbXMvcHJvYy50eHQJV2VkIE5vdiAgNyAyMzozOToz
NiAyMDAxDQorKysgbGludXgtMi40LjE5Lm5ldy9Eb2N1bWVudGF0aW9uL2Zp
bGVzeXN0ZW1zL3Byb2MudHh0CVRodSBOb3YgIDcgMTc6Mzk6MjMgMjAwMg0K
QEAgLTE1OTIsMTAgKzE1OTIsMTQgQEANCiBlcnJvcl9idXJzdCBhbmQgZXJy
b3JfY29zdA0KIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQogDQotVGhl
c2UgcGFyYW1ldGVycyAgYXJlIHVzZWQgdG8gbGltaXQgdGhlIHdhcm5pbmcg
bWVzc2FnZXMgd3JpdHRlbiB0byB0aGUga2VybmVsDQotbG9nIGZyb20gIHRo
ZSAgcm91dGluZyAgY29kZS4gIFRoZSAgaGlnaGVyIHRoZSBlcnJvcl9jb3N0
IGZhY3RvciBpcywgdGhlIGZld2VyDQotbWVzc2FnZXMgd2lsbCAgYmUgd3Jp
dHRlbi4gRXJyb3JfYnVyc3QgY29udHJvbHMgd2hlbiBtZXNzYWdlcyB3aWxs
IGJlIGRyb3BwZWQuDQotVGhlIGRlZmF1bHQgc2V0dGluZ3MgbGltaXQgd2Fy
bmluZyBtZXNzYWdlcyB0byBvbmUgZXZlcnkgZml2ZSBzZWNvbmRzLg0KK1Ro
ZXNlICBwYXJhbWV0ZXJzICBhcmUgdXNlZCB0byBsaW1pdCBob3cgbWFueSBJ
Q01QIGRlc3RpbmF0aW9uIHVucmVhY2hhYmxlIHRvIA0KK3NlbmQgIGZyb20g
IHRoZSAgaG9zdCAgaW4gcXVlc3Rpb24uIElDTVAgZGVzdGluYXRpb24gdW5y
ZWFjaGFibGUgbWVzc2FnZXMgYXJlIA0KK3NlbnQgIHdoZW4gIHdlIGNhbiBu
b3QgcmVhY2ggdGhlIG5leHQgaG9wLCB3aGlsZSB0cnlpbmcgdG8gdHJhbnNt
aXQgYSBwYWNrZXQuIA0KK0l0ICB3aWxsIGFsc28gcHJpbnQgc29tZSBlcnJv
ciBtZXNzYWdlcyB0byBrZXJuZWwgbG9ncyBpZiBzb21lb25lIGlzIGlnbm9y
aW5nIA0KK291ciAgIElDTVAgIHJlZGlyZWN0cy4gIFRoZSAgaGlnaGVyICB0
aGUgIGVycm9yX2Nvc3QgIGZhY3RvciAgaXMsICB0aGUgIGZld2VyIA0KK2Rl
c3RpbmF0aW9uICB1bnJlYWNoYWJsZSAgYW5kIGVycm9yIG1lc3NhZ2VzIHdp
bGwgYmUgbGV0IHRocm91Z2guIEVycm9yX2J1cnN0IA0KK2NvbnRyb2xzICB3
aGVuICBkZXN0aW5hdGlvbiAgdW5yZWFjaGFibGUgIG1lc3NhZ2VzIGFuZCBl
cnJvciBtZXNzYWdlcyB3aWxsIGJlDQorZHJvcHBlZC4gVGhlIGRlZmF1bHQg
c2V0dGluZ3MgbGltaXQgd2FybmluZyBtZXNzYWdlcyB0byBmaXZlIGV2ZXJ5
IHNlY29uZC4NCiANCiBmbHVzaA0KIC0tLS0tDQo=

---1463810815-1804465649-1036688435=:5001--
