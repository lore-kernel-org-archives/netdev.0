From: "yuweizheng@139.com" <yuweizheng@139.com>
Subject: Re: [PATCHv2] ath9k_htc: add adaptive usb receive
	flow control to repair soft lockup with monitor mode
Date: Mon, 16 Mar 2015 11:06:27 +0800
Message-ID: <201503161106270545805@139.com>
References: <1423528464-8433-1-git-send-email-yuweizheng@139.com>,
	<54E59A57.402@openwrt.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0850616345=="
Cc: netdev <netdev@vger.kernel.org>
To: "Felix Fietkau" <nbd@openwrt.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	ath9k-devel <ath9k-devel@lists.ath9k.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	kvalo <kvalo@codeaurora.org>, ath9k-devel <ath9k-devel@qca.qualcomm.com>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Mime-version: 1.0
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============0850616345==
Content-Type: multipart/alternative;
	boundary="----=_001_NextPart448136155231_=----"

This is a multi-part message in MIME format.

------=_001_NextPart448136155231_=----
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64

SSdtIHNvcnJ5IHRoYXQgd2UgaGF2ZSBhIGxvdCBvZiBpc3N1ZXMgYWZ0ZXIgdGhlIENoaW5lc2Ug
dHJhZGl0aW9uYWwgc3ByaW5nIGZlc3RpdmFsLiANCk5vdyBJIGNhbiBzdGFydCBmb2xsb3cgdGhp
cyBwYXRjaC4gDQogDQpUaGUgd29ya3F1ZXVlIHdpbGwgZGVsYXkgdGhlIHVyYiBzdWJtaXQgd2hp
bGUgdGhlIENQVSBoYXZlIG5vIHJlc291cmNlIHRvIHByb2Nlc3MgdGhlIHdpcmVsZXNzIHBhY2tl
dCBidWZmZXJlZCBpbiB0aGUgcnhfYnVmLiAgIEluIHRoZSBzaXR1YXRpb24sIHRoZSBvcmlnaW5h
bCBkcml2ZXIgYWx3YXlzIHN1Ym1pdCBVUkJTICwgIHRoaXMgbWF5IG1ha2UgbW9yZSByZXNvdXJj
ZSBiZSBjb25zdW1lZC4gRnVydGhlcm1vcmUsIHRoZSB0YXNrbGV0IGlzIGluIGEgZGVhZGxvb3As
IGFuZCBhIHNvZnQgbG9ja3VwIG1heWJlIGRldGVjdC4gIA0KIA0KSSBub3RpY2VkIHRoYXQgdGhp
cyB3YXkgSSB1c2UgaW4gdGhlIHBhdGNoIGlzIG5vdCB2ZXJ5IGdyYWNlZnVsLiAgSSB3aWxsIHRy
eSB0byBjb21iaW5lIHRoZSBkZWxheWVkIHN1Ym1pdCBjb2RlIHRvIHRoZSBvcmlnaW5hbCByeF90
YXNrbGV0LiAgDQoNCg0KDQp5dXdlaXpoZW5nQDEzOS5jb20NCiANCkZyb206IEZlbGl4IEZpZXRr
YXUNCkRhdGU6IDIwMTUtMDItMTkgMTY6MDkNClRvOiBZdXdlaSBaaGVuZzsgbGludXgta2VybmVs
OyBhdGg5ay1kZXZlbDsgbGludXgtd2lyZWxlc3M7IGt2YWxvOyBhdGg5ay1kZXZlbA0KQ0M6IG5l
dGRldjsgemhlbmd5dXdlaQ0KU3ViamVjdDogUmU6IFtQQVRDSHYyXSBhdGg5a19odGM6IGFkZCBh
ZGFwdGl2ZSB1c2IgcmVjZWl2ZSBmbG93IGNvbnRyb2wgdG8gcmVwYWlyIHNvZnQgbG9ja3VwIHdp
dGggbW9uaXRvciBtb2RlDQpPbiAyMDE1LTAyLTEwIDExOjM0LCBZdXdlaSBaaGVuZyB3cm90ZToN
Cj4gVGhlIGF0aDlrX2hpZl91c2JfcnhfY2IgZnVuY3Rpb24gZXhjdXRlIG9uICB0aGUgaW50ZXJy
dXB0IGNvbnRleHQsIGFuZCBhdGg5a19yeF90YXNrbGV0IGV4Y3V0ZQ0KPiBvbiB0aGUgc29mdCBp
cnEgY29udGV4dC4gSW4gb3RoZXIgd29yZHMsIHRoZSBhdGg5a19oaWZfdXNiX3J4X2NiIGhhdmUg
bW9yZSBjaGFuY2UgdG8gZXhjdXRlIHRoYW4NCj4gYXRoOWtfcnhfdGFza2xldC4gIFNvIGluIHRo
ZSB3b3JzdCBjb25kaXRpb24sICB0aGUgcngucnhidWYgcmVjZWl2ZSBsaXN0IGlzIGFsd2F5cyBm
dWxsLA0KPiBhbmQgdGhlIGRvIHt9d2hpbGUodHJ1ZSkgbG9vcCB3aWxsIG5vdCBiZSBicmVhay4g
VGhlIGtlcm5lbCBnZXQgYSBzb2Z0IGxvY2t1cCBwYW5pYy4gDQo+ICANCj4gWzU5MDExLjAwNzIx
MF0gQlVHOiBzb2Z0IGxvY2t1cCAtIENQVSMwIHN0dWNrIGZvciAyM3MhDQo+IFtrd29ya2VyLzA6
MDozMDYwOV0NCj4gWzU5MDExLjAzMDU2MF0gQlVHOiBzY2hlZHVsaW5nIHdoaWxlIGF0b21pYzog
a3dvcmtlci8wOjAvMzA2MDkvMHg0MDAxMDEwMA0KPiBbNTkwMTMuODA0NDg2XSBCVUc6IHNjaGVk
dWxpbmcgd2hpbGUgYXRvbWljOiBrd29ya2VyLzA6MC8zMDYwOS8weDQwMDEwMTAwDQo+IFs1OTAx
My44NTg1MjJdIEtlcm5lbCBwYW5pYyAtIG5vdCBzeW5jaW5nOiBzb2Z0bG9ja3VwOiBodW5nIHRh
c2tzDQo+ICANCj4gWzU5MDE0LjAzODg5MV0gRXhjZXB0aW9uIHN0YWNrKDB4ZGY0YmJjMzggdG8g
MHhkZjRiYmM4MCkNCj4gWzU5MDE0LjA0NjgzNF0gYmMyMDogICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgZGU1N2I5NTAgNjAwMDAxMTMNCj4gWzU5
MDE0LjA1OTU3OV0gYmM0MDogMDAwMDAwMDAgYmIzMmJiMzIgNjAwMDAxMTMgZGU1N2I5NDggZGU1
N2I1MDAgZGM3YmI0NDAgZGY0YmJjZDAgMDAwMDAwMDANCj4gWzU5MDE0LjA3MjMzN10gYmM2MDog
ZGU1N2I5NTAgNjAwMDAxMTMgZGY0YmJjZDAgZGY0YmJjODAgYzA0YzI1OWQgYzA0YzI1YTAgNjAw
MDAxMzMgZmZmZmZmZmYNCj4gWzU5MDE0LjA4NTIzM10gWzxjMDRjMjhkYj5dIChfX2lycV9zdmMr
MHgzYi8weDVjKSBmcm9tIFs8YzA0YzI1YTA+XSAoX3Jhd19zcGluX3VubG9ja19pcnFyZXN0b3Jl
KzB4Yy8weDEwKQ0KPiBbNTkwMTQuMTAwNDM3XSBbPGMwNGMyNWEwPl0gKF9yYXdfc3Bpbl91bmxv
Y2tfaXJxcmVzdG9yZSsweGMvMHgxMCkgZnJvbSBbPGJmOWMyMDg5Pl0gKGF0aDlrX3J4X3Rhc2ts
ZXQrMHgyOTAvMHg0OTAgW2F0aDlrX2h0Y10pDQo+IFs1OTAxNC4xMTgyNjddIFs8YmY5YzIwODk+
XSAoYXRoOWtfcnhfdGFza2xldCsweDI5MC8weDQ5MCBbYXRoOWtfaHRjXSkgZnJvbSBbPGMwMDM2
ZDIzPl0gKHRhc2tsZXRfYWN0aW9uKzB4M2IvMHg5OCkNCj4gWzU5MDE0LjEzNDEzMl0gWzxjMDAz
NmQyMz5dICh0YXNrbGV0X2FjdGlvbisweDNiLzB4OTgpIGZyb20gWzxjMDAzNjcwOT5dIChfX2Rv
X3NvZnRpcnErMHg5OS8weDE2YykNCj4gWzU5MDE0LjE0Nzc4NF0gWzxjMDAzNjcwOT5dIChfX2Rv
X3NvZnRpcnErMHg5OS8weDE2YykgZnJvbSBbPGMwMDM2OWY3Pl0gKGlycV9leGl0KzB4NWIvMHg1
YykNCj4gWzU5MDE0LjE2MDY1M10gWzxjMDAzNjlmNz5dIChpcnFfZXhpdCsweDViLzB4NWMpIGZy
b20gWzxjMDAwY2ZjMz5dIChoYW5kbGVfSVJRKzB4MzcvMHg3OCkNCj4gWzU5MDE0LjE3MzEyNF0g
WzxjMDAwY2ZjMz5dIChoYW5kbGVfSVJRKzB4MzcvMHg3OCkgZnJvbSBbPGMwMDA4NWRmPl0gKG9t
YXAzX2ludGNfaGFuZGxlX2lycSsweDVmLzB4NjgpDQo+IFs1OTAxNC4xODcyMjVdIFs8YzAwMDg1
ZGY+XSAob21hcDNfaW50Y19oYW5kbGVfaXJxKzB4NWYvMHg2OCkgZnJvbSBbPGMwNGMyOGRiPl0o
X19pcnFfc3ZjKzB4M2IvMHg1YykNCj4gIA0KPiBUaGlzIGJ1ZyBjYW4gYmUgc2VlIHdpdGggbG93
IHBlcmZvcm1hbmNlIGJvYXJkLCBzdWNoIGFzIHVuaXByb2Nlc3NvciBiZWFnbGUgYm9uZSBib2Fy
ZC4gQWRkIHNvbWUgZGVidWcgDQo+IG1lc3NhZ2UgaW4gdGhlIGF0aDlrX2hpZl91c2JfcnhfY2Ig
ZnVuY3Rpb24gbWF5IHRyaWdnZXIgdGhpcyBidWcgcXVpY2tseS4NCj4gIA0KPiBTaWduZWQtb2Zm
LWJ5OiBZdXdlaSBaaGVuZyA8eXV3ZWl6aGVuZ0AxMzkuY29tPg0KVGhpcyBhcHByb2FjaCBvZiBp
bnRlcmFjdGlvbiBiZXR3ZWVuIHRhc2tsZXQgYW5kIHdvcmtxdWV1ZSBwcm9jZXNzaW5nDQpzZWVt
cyBxdWl0ZSBjb21wbGV4IHRvIG1lLiBXb3VsZG4ndCBpdCBiZSBzaW1wbGVyIGFuZCBiZXR0ZXIg
dG8gc2ltcGx5DQphbHdheXMgcnVuIHRoZSByeCBwcm9jZXNzaW5nIGNvZGUgaW4gd29ya3F1ZXVl
IGNvbnRleHQ/DQpUaGF0IHdheSBpdCBjYW4gZ28gb24gcHJvY2Vzc2luZyBmb3JldmVyIChhcyBs
b25nIGFzIHRoZXJlIGlzIGRhdGEgdG8gYmUNCnJlY2VpdmVkKSwgd2hpbGUgdGhlIHNjaGVkdWxl
ciBlbnN1cmVzIHRoYXQgaXQgZG9lc24ndCBpbnRlcmZlcmUgd2l0aA0Kb3RoZXIgY3JpdGljYWwg
d29yayBvbiB0aGUgQ1BVLg0KIA0KLSBGZWxpeA0K

------=_001_NextPart448136155231_=----
Content-Type: text/html;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable

<html><head><meta http-equiv=3D"content-type" content=3D"text/html; charse=
t=3Dutf-8"><style>body { line-height: 1.5; }blockquote { margin-top: 0px; =
margin-bottom: 0px; margin-left: 0.5em; }p { margin-top: 0px; margin-botto=
m: 0px; }body { font-size: 10.5pt; font-family: =E5=BE=AE=E8=BD=AF=E9=9B=
=85=E9=BB=91; color: rgb(0, 0, 0); line-height: 1.5; }</style></head><body=
>=0A<div><span></span><!--[if gte mso 9]><xml>=0A <o:OfficeDocumentSetting=
s>=0A  <o:AllowPNG></o:AllowPNG>=0A </o:OfficeDocumentSettings>=0A</xml><!=
[endif]-->=0A<!--[if gte mso 9]><xml>=0A <w:WordDocument>=0A  <w:View>Norm=
al</w:View>=0A  <w:Zoom>0</w:Zoom>=0A  <w:TrackMoves></w:TrackMoves>=0A  <=
w:TrackFormatting></w:TrackFormatting>=0A  <w:PunctuationKerning></w:Punct=
uationKerning>=0A  <w:ValidateAgainstSchemas></w:ValidateAgainstSchemas>=
=0A  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>=0A  <w:IgnoreMixedCont=
ent>false</w:IgnoreMixedContent>=0A  <w:AlwaysShowPlaceholderText>false</w=
:AlwaysShowPlaceholderText>=0A  <w:DoNotPromoteQF></w:DoNotPromoteQF>=0A  =
<w:LidThemeOther>EN-US</w:LidThemeOther>=0A  <w:LidThemeAsian>ZH-CN</w:Lid=
ThemeAsian>=0A  <w:LidThemeComplexScript>X-NONE</w:LidThemeComplexScript>=
=0A  <w:Compatibility>=0A   <w:BreakWrappedTables></w:BreakWrappedTables>=
=0A   <w:SnapToGridInCell></w:SnapToGridInCell>=0A   <w:WrapTextWithPunct>=
</w:WrapTextWithPunct>=0A   <w:UseAsianBreakRules></w:UseAsianBreakRules>=
=0A   <w:DontGrowAutofit></w:DontGrowAutofit>=0A   <w:SplitPgBreakAndParaM=
ark></w:SplitPgBreakAndParaMark>=0A   <w:EnableOpenTypeKerning></w:EnableO=
penTypeKerning>=0A   <w:DontFlipMirrorIndents></w:DontFlipMirrorIndents>=
=0A   <w:OverrideTableStyleHps></w:OverrideTableStyleHps>=0A   <w:UseFELay=
out></w:UseFELayout>=0A  </w:Compatibility>=0A  <m:mathPr>=0A   <m:mathFon=
t m:val=3D"Cambria Math"></m:mathFont>=0A   <m:brkBin m:val=3D"before"></m=
:brkBin>=0A   <m:brkBinSub m:val=3D"&#45;-"></m:brkBinSub>=0A   <m:smallFr=
ac m:val=3D"off"></m:smallFrac>=0A   <m:dispDef></m:dispDef>=0A   <m:lMarg=
in m:val=3D"0"></m:lMargin>=0A   <m:rMargin m:val=3D"0"></m:rMargin>=0A   =
<m:defJc m:val=3D"centerGroup"></m:defJc>=0A   <m:wrapIndent m:val=3D"1440=
"></m:wrapIndent>=0A   <m:intLim m:val=3D"subSup"></m:intLim>=0A   <m:nary=
Lim m:val=3D"undOvr"></m:naryLim>=0A  </m:mathPr></w:WordDocument>=0A</xml=
><![endif]--><!--[if gte mso 9]><xml>=0A <w:LatentStyles DefLockedState=3D=
"false" DefUnhideWhenUsed=3D"true"=0A  DefSemiHidden=3D"true" DefQFormat=
=3D"false" DefPriority=3D"99"=0A  LatentStyleCount=3D"267">=0A  <w:LsdExce=
ption Locked=3D"false" Priority=3D"0" SemiHidden=3D"false"=0A   UnhideWhen=
Used=3D"false" QFormat=3D"true" Name=3D"Normal"></w:LsdException>=0A  <w:L=
sdException Locked=3D"false" Priority=3D"9" SemiHidden=3D"false"=0A   Unhi=
deWhenUsed=3D"false" QFormat=3D"true" Name=3D"heading 1"></w:LsdException>=
=0A  <w:LsdException Locked=3D"false" Priority=3D"9" QFormat=3D"true" Name=
=3D"heading 2"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Prio=
rity=3D"9" QFormat=3D"true" Name=3D"heading 3"></w:LsdException>=0A  <w:Ls=
dException Locked=3D"false" Priority=3D"9" QFormat=3D"true" Name=3D"headin=
g 4"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"9"=
 QFormat=3D"true" Name=3D"heading 5"></w:LsdException>=0A  <w:LsdException=
 Locked=3D"false" Priority=3D"9" QFormat=3D"true" Name=3D"heading 6"></w:L=
sdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"9" QFormat=
=3D"true" Name=3D"heading 7"></w:LsdException>=0A  <w:LsdException Locked=
=3D"false" Priority=3D"9" QFormat=3D"true" Name=3D"heading 8"></w:LsdExcep=
tion>=0A  <w:LsdException Locked=3D"false" Priority=3D"9" QFormat=3D"true"=
 Name=3D"heading 9"></w:LsdException>=0A  <w:LsdException Locked=3D"false"=
 Priority=3D"39" Name=3D"toc 1"></w:LsdException>=0A  <w:LsdException Lock=
ed=3D"false" Priority=3D"39" Name=3D"toc 2"></w:LsdException>=0A  <w:LsdEx=
ception Locked=3D"false" Priority=3D"39" Name=3D"toc 3"></w:LsdException>=
=0A  <w:LsdException Locked=3D"false" Priority=3D"39" Name=3D"toc 4"></w:L=
sdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"39" Name=3D"=
toc 5"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"=
39" Name=3D"toc 6"></w:LsdException>=0A  <w:LsdException Locked=3D"false" =
Priority=3D"39" Name=3D"toc 7"></w:LsdException>=0A  <w:LsdException Locke=
d=3D"false" Priority=3D"39" Name=3D"toc 8"></w:LsdException>=0A  <w:LsdExc=
eption Locked=3D"false" Priority=3D"39" Name=3D"toc 9"></w:LsdException>=
=0A  <w:LsdException Locked=3D"false" Priority=3D"35" QFormat=3D"true" Nam=
e=3D"caption"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Prior=
ity=3D"10" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" QFormat=3D"t=
rue" Name=3D"Title"></w:LsdException>=0A  <w:LsdException Locked=3D"false"=
 Priority=3D"1" Name=3D"Default Paragraph Font"></w:LsdException>=0A  <w:L=
sdException Locked=3D"false" Priority=3D"11" SemiHidden=3D"false"=0A   Unh=
ideWhenUsed=3D"false" QFormat=3D"true" Name=3D"Subtitle"></w:LsdException>=
=0A  <w:LsdException Locked=3D"false" Priority=3D"22" SemiHidden=3D"false"=
=0A   UnhideWhenUsed=3D"false" QFormat=3D"true" Name=3D"Strong"></w:LsdExc=
eption>=0A  <w:LsdException Locked=3D"false" Priority=3D"20" SemiHidden=3D=
"false"=0A   UnhideWhenUsed=3D"false" QFormat=3D"true" Name=3D"Emphasis"><=
/w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"59" Semi=
Hidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Table Grid"></w:Lsd=
Exception>=0A  <w:LsdException Locked=3D"false" UnhideWhenUsed=3D"false" N=
ame=3D"Placeholder Text"></w:LsdException>=0A  <w:LsdException Locked=3D"f=
alse" Priority=3D"1" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" QF=
ormat=3D"true" Name=3D"No Spacing"></w:LsdException>=0A  <w:LsdException L=
ocked=3D"false" Priority=3D"60" SemiHidden=3D"false"=0A   UnhideWhenUsed=
=3D"false" Name=3D"Light Shading"></w:LsdException>=0A  <w:LsdException Lo=
cked=3D"false" Priority=3D"61" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D=
"false" Name=3D"Light List"></w:LsdException>=0A  <w:LsdException Locked=
=3D"false" Priority=3D"62" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"fal=
se" Name=3D"Light Grid"></w:LsdException>=0A  <w:LsdException Locked=3D"fa=
lse" Priority=3D"63" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Na=
me=3D"Medium Shading 1"></w:LsdException>=0A  <w:LsdException Locked=3D"fa=
lse" Priority=3D"64" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Na=
me=3D"Medium Shading 2"></w:LsdException>=0A  <w:LsdException Locked=3D"fa=
lse" Priority=3D"65" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Na=
me=3D"Medium List 1"></w:LsdException>=0A  <w:LsdException Locked=3D"false=
" Priority=3D"66" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=
=3D"Medium List 2"></w:LsdException>=0A  <w:LsdException Locked=3D"false" =
Priority=3D"67" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D=
"Medium Grid 1"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Pri=
ority=3D"68" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Me=
dium Grid 2"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priori=
ty=3D"69" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Mediu=
m Grid 3"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=
=3D"70" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Dark Li=
st"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"71"=
 SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Colorful Shadi=
ng"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"72"=
 SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Colorful List"=
></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"73" Se=
miHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Colorful Grid"></=
w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"60" SemiH=
idden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Light Shading Accent=
 1"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"61"=
 SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Light List Acc=
ent 1"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"=
62" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Light Grid =
Accent 1"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=
=3D"63" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium =
Shading 1 Accent 1"></w:LsdException>=0A  <w:LsdException Locked=3D"false"=
 Priority=3D"64" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=
=3D"Medium Shading 2 Accent 1"></w:LsdException>=0A  <w:LsdException Locke=
d=3D"false" Priority=3D"65" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"fa=
lse" Name=3D"Medium List 1 Accent 1"></w:LsdException>=0A  <w:LsdException=
 Locked=3D"false" UnhideWhenUsed=3D"false" Name=3D"Revision"></w:LsdExcept=
ion>=0A  <w:LsdException Locked=3D"false" Priority=3D"34" SemiHidden=3D"fa=
lse"=0A   UnhideWhenUsed=3D"false" QFormat=3D"true" Name=3D"List Paragraph=
"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"29" S=
emiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" QFormat=3D"true" Name=3D=
"Quote"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D=
"30" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" QFormat=3D"true" N=
ame=3D"Intense Quote"></w:LsdException>=0A  <w:LsdException Locked=3D"fals=
e" Priority=3D"66" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=
=3D"Medium List 2 Accent 1"></w:LsdException>=0A  <w:LsdException Locked=
=3D"false" Priority=3D"67" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"fal=
se" Name=3D"Medium Grid 1 Accent 1"></w:LsdException>=0A  <w:LsdException =
Locked=3D"false" Priority=3D"68" SemiHidden=3D"false"=0A   UnhideWhenUsed=
=3D"false" Name=3D"Medium Grid 2 Accent 1"></w:LsdException>=0A  <w:LsdExc=
eption Locked=3D"false" Priority=3D"69" SemiHidden=3D"false"=0A   UnhideWh=
enUsed=3D"false" Name=3D"Medium Grid 3 Accent 1"></w:LsdException>=0A  <w:=
LsdException Locked=3D"false" Priority=3D"70" SemiHidden=3D"false"=0A   Un=
hideWhenUsed=3D"false" Name=3D"Dark List Accent 1"></w:LsdException>=0A  <=
w:LsdException Locked=3D"false" Priority=3D"71" SemiHidden=3D"false"=0A   =
UnhideWhenUsed=3D"false" Name=3D"Colorful Shading Accent 1"></w:LsdExcepti=
on>=0A  <w:LsdException Locked=3D"false" Priority=3D"72" SemiHidden=3D"fal=
se"=0A   UnhideWhenUsed=3D"false" Name=3D"Colorful List Accent 1"></w:LsdE=
xception>=0A  <w:LsdException Locked=3D"false" Priority=3D"73" SemiHidden=
=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Colorful Grid Accent 1"><=
/w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"60" Semi=
Hidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Light Shading Accen=
t 2"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"61=
" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Light List Ac=
cent 2"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D=
"62" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Light Grid=
 Accent 2"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=
=3D"63" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium =
Shading 1 Accent 2"></w:LsdException>=0A  <w:LsdException Locked=3D"false"=
 Priority=3D"64" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=
=3D"Medium Shading 2 Accent 2"></w:LsdException>=0A  <w:LsdException Locke=
d=3D"false" Priority=3D"65" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"fa=
lse" Name=3D"Medium List 1 Accent 2"></w:LsdException>=0A  <w:LsdException=
 Locked=3D"false" Priority=3D"66" SemiHidden=3D"false"=0A   UnhideWhenUsed=
=3D"false" Name=3D"Medium List 2 Accent 2"></w:LsdException>=0A  <w:LsdExc=
eption Locked=3D"false" Priority=3D"67" SemiHidden=3D"false"=0A   UnhideWh=
enUsed=3D"false" Name=3D"Medium Grid 1 Accent 2"></w:LsdException>=0A  <w:=
LsdException Locked=3D"false" Priority=3D"68" SemiHidden=3D"false"=0A   Un=
hideWhenUsed=3D"false" Name=3D"Medium Grid 2 Accent 2"></w:LsdException>=
=0A  <w:LsdException Locked=3D"false" Priority=3D"69" SemiHidden=3D"false"=
=0A   UnhideWhenUsed=3D"false" Name=3D"Medium Grid 3 Accent 2"></w:LsdExce=
ption>=0A  <w:LsdException Locked=3D"false" Priority=3D"70" SemiHidden=3D"=
false"=0A   UnhideWhenUsed=3D"false" Name=3D"Dark List Accent 2"></w:LsdEx=
ception>=0A  <w:LsdException Locked=3D"false" Priority=3D"71" SemiHidden=
=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Colorful Shading Accent 2=
"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"72" S=
emiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Colorful List Ac=
cent 2"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D=
"73" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Colorful G=
rid Accent 2"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Prior=
ity=3D"60" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Ligh=
t Shading Accent 3"></w:LsdException>=0A  <w:LsdException Locked=3D"false"=
 Priority=3D"61" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=
=3D"Light List Accent 3"></w:LsdException>=0A  <w:LsdException Locked=3D"f=
alse" Priority=3D"62" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" N=
ame=3D"Light Grid Accent 3"></w:LsdException>=0A  <w:LsdException Locked=
=3D"false" Priority=3D"63" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"fal=
se" Name=3D"Medium Shading 1 Accent 3"></w:LsdException>=0A  <w:LsdExcepti=
on Locked=3D"false" Priority=3D"64" SemiHidden=3D"false"=0A   UnhideWhenUs=
ed=3D"false" Name=3D"Medium Shading 2 Accent 3"></w:LsdException>=0A  <w:L=
sdException Locked=3D"false" Priority=3D"65" SemiHidden=3D"false"=0A   Unh=
ideWhenUsed=3D"false" Name=3D"Medium List 1 Accent 3"></w:LsdException>=0A=
  <w:LsdException Locked=3D"false" Priority=3D"66" SemiHidden=3D"false"=0A=
   UnhideWhenUsed=3D"false" Name=3D"Medium List 2 Accent 3"></w:LsdExcepti=
on>=0A  <w:LsdException Locked=3D"false" Priority=3D"67" SemiHidden=3D"fal=
se"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium Grid 1 Accent 3"></w:LsdE=
xception>=0A  <w:LsdException Locked=3D"false" Priority=3D"68" SemiHidden=
=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium Grid 2 Accent 3"><=
/w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"69" Semi=
Hidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium Grid 3 Accen=
t 3"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"70=
" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Dark List Acc=
ent 3"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"=
71" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Colorful Sh=
ading Accent 3"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Pri=
ority=3D"72" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Co=
lorful List Accent 3"></w:LsdException>=0A  <w:LsdException Locked=3D"fals=
e" Priority=3D"73" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=
=3D"Colorful Grid Accent 3"></w:LsdException>=0A  <w:LsdException Locked=
=3D"false" Priority=3D"60" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"fal=
se" Name=3D"Light Shading Accent 4"></w:LsdException>=0A  <w:LsdException =
Locked=3D"false" Priority=3D"61" SemiHidden=3D"false"=0A   UnhideWhenUsed=
=3D"false" Name=3D"Light List Accent 4"></w:LsdException>=0A  <w:LsdExcept=
ion Locked=3D"false" Priority=3D"62" SemiHidden=3D"false"=0A   UnhideWhenU=
sed=3D"false" Name=3D"Light Grid Accent 4"></w:LsdException>=0A  <w:LsdExc=
eption Locked=3D"false" Priority=3D"63" SemiHidden=3D"false"=0A   UnhideWh=
enUsed=3D"false" Name=3D"Medium Shading 1 Accent 4"></w:LsdException>=0A  =
<w:LsdException Locked=3D"false" Priority=3D"64" SemiHidden=3D"false"=0A  =
 UnhideWhenUsed=3D"false" Name=3D"Medium Shading 2 Accent 4"></w:LsdExcept=
ion>=0A  <w:LsdException Locked=3D"false" Priority=3D"65" SemiHidden=3D"fa=
lse"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium List 1 Accent 4"></w:Lsd=
Exception>=0A  <w:LsdException Locked=3D"false" Priority=3D"66" SemiHidden=
=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium List 2 Accent 4"><=
/w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"67" Semi=
Hidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium Grid 1 Accen=
t 4"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"68=
" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium Grid 2=
 Accent 4"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=
=3D"69" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium =
Grid 3 Accent 4"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Pr=
iority=3D"70" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"D=
ark List Accent 4"></w:LsdException>=0A  <w:LsdException Locked=3D"false" =
Priority=3D"71" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D=
"Colorful Shading Accent 4"></w:LsdException>=0A  <w:LsdException Locked=
=3D"false" Priority=3D"72" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"fal=
se" Name=3D"Colorful List Accent 4"></w:LsdException>=0A  <w:LsdException =
Locked=3D"false" Priority=3D"73" SemiHidden=3D"false"=0A   UnhideWhenUsed=
=3D"false" Name=3D"Colorful Grid Accent 4"></w:LsdException>=0A  <w:LsdExc=
eption Locked=3D"false" Priority=3D"60" SemiHidden=3D"false"=0A   UnhideWh=
enUsed=3D"false" Name=3D"Light Shading Accent 5"></w:LsdException>=0A  <w:=
LsdException Locked=3D"false" Priority=3D"61" SemiHidden=3D"false"=0A   Un=
hideWhenUsed=3D"false" Name=3D"Light List Accent 5"></w:LsdException>=0A  =
<w:LsdException Locked=3D"false" Priority=3D"62" SemiHidden=3D"false"=0A  =
 UnhideWhenUsed=3D"false" Name=3D"Light Grid Accent 5"></w:LsdException>=
=0A  <w:LsdException Locked=3D"false" Priority=3D"63" SemiHidden=3D"false"=
=0A   UnhideWhenUsed=3D"false" Name=3D"Medium Shading 1 Accent 5"></w:LsdE=
xception>=0A  <w:LsdException Locked=3D"false" Priority=3D"64" SemiHidden=
=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium Shading 2 Accent 5=
"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"65" S=
emiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium List 1 Ac=
cent 5"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D=
"66" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium Lis=
t 2 Accent 5"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Prior=
ity=3D"67" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medi=
um Grid 1 Accent 5"></w:LsdException>=0A  <w:LsdException Locked=3D"false"=
 Priority=3D"68" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=
=3D"Medium Grid 2 Accent 5"></w:LsdException>=0A  <w:LsdException Locked=
=3D"false" Priority=3D"69" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"fal=
se" Name=3D"Medium Grid 3 Accent 5"></w:LsdException>=0A  <w:LsdException =
Locked=3D"false" Priority=3D"70" SemiHidden=3D"false"=0A   UnhideWhenUsed=
=3D"false" Name=3D"Dark List Accent 5"></w:LsdException>=0A  <w:LsdExcepti=
on Locked=3D"false" Priority=3D"71" SemiHidden=3D"false"=0A   UnhideWhenUs=
ed=3D"false" Name=3D"Colorful Shading Accent 5"></w:LsdException>=0A  <w:L=
sdException Locked=3D"false" Priority=3D"72" SemiHidden=3D"false"=0A   Unh=
ideWhenUsed=3D"false" Name=3D"Colorful List Accent 5"></w:LsdException>=0A=
  <w:LsdException Locked=3D"false" Priority=3D"73" SemiHidden=3D"false"=0A=
   UnhideWhenUsed=3D"false" Name=3D"Colorful Grid Accent 5"></w:LsdExcepti=
on>=0A  <w:LsdException Locked=3D"false" Priority=3D"60" SemiHidden=3D"fal=
se"=0A   UnhideWhenUsed=3D"false" Name=3D"Light Shading Accent 6"></w:LsdE=
xception>=0A  <w:LsdException Locked=3D"false" Priority=3D"61" SemiHidden=
=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Light List Accent 6"></w:=
LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"62" SemiHid=
den=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Light Grid Accent 6"><=
/w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"63" Semi=
Hidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium Shading 1 Ac=
cent 6"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D=
"64" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Medium Sha=
ding 2 Accent 6"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Pr=
iority=3D"65" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"M=
edium List 1 Accent 6"></w:LsdException>=0A  <w:LsdException Locked=3D"fal=
se" Priority=3D"66" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" Nam=
e=3D"Medium List 2 Accent 6"></w:LsdException>=0A  <w:LsdException Locked=
=3D"false" Priority=3D"67" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"fal=
se" Name=3D"Medium Grid 1 Accent 6"></w:LsdException>=0A  <w:LsdException =
Locked=3D"false" Priority=3D"68" SemiHidden=3D"false"=0A   UnhideWhenUsed=
=3D"false" Name=3D"Medium Grid 2 Accent 6"></w:LsdException>=0A  <w:LsdExc=
eption Locked=3D"false" Priority=3D"69" SemiHidden=3D"false"=0A   UnhideWh=
enUsed=3D"false" Name=3D"Medium Grid 3 Accent 6"></w:LsdException>=0A  <w:=
LsdException Locked=3D"false" Priority=3D"70" SemiHidden=3D"false"=0A   Un=
hideWhenUsed=3D"false" Name=3D"Dark List Accent 6"></w:LsdException>=0A  <=
w:LsdException Locked=3D"false" Priority=3D"71" SemiHidden=3D"false"=0A   =
UnhideWhenUsed=3D"false" Name=3D"Colorful Shading Accent 6"></w:LsdExcepti=
on>=0A  <w:LsdException Locked=3D"false" Priority=3D"72" SemiHidden=3D"fal=
se"=0A   UnhideWhenUsed=3D"false" Name=3D"Colorful List Accent 6"></w:LsdE=
xception>=0A  <w:LsdException Locked=3D"false" Priority=3D"73" SemiHidden=
=3D"false"=0A   UnhideWhenUsed=3D"false" Name=3D"Colorful Grid Accent 6"><=
/w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"19" Semi=
Hidden=3D"false"=0A   UnhideWhenUsed=3D"false" QFormat=3D"true" Name=3D"Su=
btle Emphasis"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Prio=
rity=3D"21" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"false" QFormat=3D"=
true" Name=3D"Intense Emphasis"></w:LsdException>=0A  <w:LsdException Lock=
ed=3D"false" Priority=3D"31" SemiHidden=3D"false"=0A   UnhideWhenUsed=3D"f=
alse" QFormat=3D"true" Name=3D"Subtle Reference"></w:LsdException>=0A  <w:=
LsdException Locked=3D"false" Priority=3D"32" SemiHidden=3D"false"=0A   Un=
hideWhenUsed=3D"false" QFormat=3D"true" Name=3D"Intense Reference"></w:Lsd=
Exception>=0A  <w:LsdException Locked=3D"false" Priority=3D"33" SemiHidden=
=3D"false"=0A   UnhideWhenUsed=3D"false" QFormat=3D"true" Name=3D"Book Tit=
le"></w:LsdException>=0A  <w:LsdException Locked=3D"false" Priority=3D"37"=
 Name=3D"Bibliography"></w:LsdException>=0A  <w:LsdException Locked=3D"fal=
se" Priority=3D"39" QFormat=3D"true" Name=3D"TOC Heading"></w:LsdException=
>=0A </w:LatentStyles>=0A</xml><![endif]-->=0A<!--[if gte mso 10]>=0A<styl=
e>=0A /* Style Definitions */=0A table.MsoNormalTable=0A	{mso-style-name:=
=E6=99=AE=E9=80=9A=E8=A1=A8=E6=A0=BC;=0A	mso-tstyle-rowband-size:0;=0A	mso=
-tstyle-colband-size:0;=0A	mso-style-noshow:yes;=0A	mso-style-priority:99;=
=0A	mso-style-parent:"";=0A	mso-padding-alt:0cm 5.4pt 0cm 5.4pt;=0A	mso-pa=
ra-margin-top:0cm;=0A	mso-para-margin-right:0cm;=0A	mso-para-margin-bottom=
:10.0pt;=0A	mso-para-margin-left:0cm;=0A	line-height:115%;=0A	mso-paginati=
on:widow-orphan;=0A	font-size:11.0pt;=0A	font-family:"Calibri","sans-serif=
";=0A	mso-ascii-font-family:Calibri;=0A	mso-ascii-theme-font:minor-latin;=
=0A	mso-hansi-font-family:Calibri;=0A	mso-hansi-theme-font:minor-latin;}=
=0A</style>=0A<![endif]-->=0A<!--StartFragment-->=0A<p class=3D"MsoPlainTe=
xt" style=3D"margin: 0cm 0cm 0.0001pt; font-size: 11pt; font-family: Calib=
ri, sans-serif;">I'm sorry that we have a lot of issues after the Chinese=
=0Atraditional spring festival. <o:p></o:p></p>=0A<p class=3D"MsoPlainText=
" style=3D"margin: 0cm 0cm 0.0001pt; font-size: 11pt; font-family: Calibri=
, sans-serif;">Now I can start follow this patch. <o:p></o:p></p>=0A<p cla=
ss=3D"MsoPlainText" style=3D"margin: 0cm 0cm 0.0001pt; font-size: 11pt; fo=
nt-family: Calibri, sans-serif;"><o:p>&nbsp;</o:p></p>=0A<p class=3D"MsoPl=
ainText" style=3D"margin: 0cm 0cm 0.0001pt; font-size: 11pt; font-family: =
Calibri, sans-serif;">The workqueue will delay the urb submit while the CP=
U have=0Ano resource to process the wireless packet buffered in the rx_buf=
.&nbsp; &nbsp;In the=0Asituation, the original driver always submit URBS ,=
 &nbsp;this may make more resource be consumed. Furthermore,=0Athe tasklet=
 is in a deadloop, and a soft lockup maybe detect. &nbsp;<o:p></o:p></p>=
=0A<p class=3D"MsoPlainText" style=3D"margin: 0cm 0cm 0.0001pt; font-size:=
 11pt; font-family: Calibri, sans-serif;"><o:p>&nbsp;</o:p></p>=0A<p class=
=3D"MsoPlainText" style=3D"margin: 0cm 0cm 0.0001pt; font-size: 11pt; font=
-family: Calibri, sans-serif;">I noticed that this way I use in the patch =
is not very graceful.=0A&nbsp;I will try to combine the delayed submit=0Ac=
ode to the original rx_tasklet. &nbsp;<o:p></o:p></p>=0A<!--EndFragment-->=
</div>=0A<div><br></div><hr style=3D"width: 210px; height: 1px;" color=3D"=
#b5c4df" size=3D"1" align=3D"left">=0A<div><span><div style=3D"MARGIN: 10p=
x; FONT-FAMILY: verdana; FONT-SIZE: 10pt"><div>yuweizheng@139.com</div></d=
iv></span></div>=0A<blockquote style=3D"margin-top: 0px; margin-bottom: 0p=
x; margin-left: 0.5em;"><div>&nbsp;</div><div style=3D"border:none;border-=
top:solid #B5C4DF 1.0pt;padding:3.0pt 0cm 0cm 0cm"><div style=3D"PADDING-R=
IGHT: 8px; PADDING-LEFT: 8px; FONT-SIZE: 12px;FONT-FAMILY:tahoma;COLOR:#00=
0000; BACKGROUND: #efefef; PADDING-BOTTOM: 8px; PADDING-TOP: 8px"><div><b>=
From:</b>&nbsp;<a href=3D"mailto:nbd@openwrt.org">Felix Fietkau</a></div><=
div><b>Date:</b>&nbsp;2015-02-19&nbsp;16:09</div><div><b>To:</b>&nbsp;<a h=
ref=3D"mailto:yuweizheng@139.com">Yuwei Zheng</a>; <a href=3D"mailto:linux=
-kernel@vger.kernel.org">linux-kernel</a>; <a href=3D"mailto:ath9k-devel@l=
ists.ath9k.org">ath9k-devel</a>; <a href=3D"mailto:linux-wireless@vger.ker=
nel.org">linux-wireless</a>; <a href=3D"mailto:kvalo@codeaurora.org">kvalo=
</a>; <a href=3D"mailto:ath9k-devel@qca.qualcomm.com">ath9k-devel</a></div=
><div><b>CC:</b>&nbsp;<a href=3D"mailto:netdev@vger.kernel.org">netdev</a>=
; <a href=3D"mailto:zhengyuwei@360.cn">zhengyuwei</a></div><div><b>Subject=
:</b>&nbsp;Re: [PATCHv2] ath9k_htc: add adaptive usb receive flow control =
to repair soft lockup with monitor mode</div></div></div><div><div>On 2015=
-02-10 11:34, Yuwei Zheng wrote:</div>=0A<div>&gt; The ath9k_hif_usb_rx_cb=
 function excute on&nbsp; the interrupt context, and ath9k_rx_tasklet excu=
te</div>=0A<div>&gt; on the soft irq context. In other words, the ath9k_hi=
f_usb_rx_cb have more chance to excute than</div>=0A<div>&gt; ath9k_rx_tas=
klet.&nbsp; So in the worst condition,&nbsp; the rx.rxbuf receive list is =
always full,</div>=0A<div>&gt; and the do {}while(true) loop will not be b=
reak. The kernel get a soft lockup panic. </div>=0A<div>&gt;&nbsp; </div>=
=0A<div>&gt; [59011.007210] BUG: soft lockup - CPU#0 stuck for 23s!</div>=
=0A<div>&gt; [kworker/0:0:30609]</div>=0A<div>&gt; [59011.030560] BUG: sch=
eduling while atomic: kworker/0:0/30609/0x40010100</div>=0A<div>&gt; [5901=
3.804486] BUG: scheduling while atomic: kworker/0:0/30609/0x40010100</div>=
=0A<div>&gt; [59013.858522] Kernel panic - not syncing: softlockup: hung t=
asks</div>=0A<div>&gt;&nbsp; </div>=0A<div>&gt; [59014.038891] Exception s=
tack(0xdf4bbc38 to 0xdf4bbc80)</div>=0A<div>&gt; [59014.046834] bc20:&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; de57b950 60000113</div>=0A<div>&gt; [59014.059579]=
 bc40: 00000000 bb32bb32 60000113 de57b948 de57b500 dc7bb440 df4bbcd0 0000=
0000</div>=0A<div>&gt; [59014.072337] bc60: de57b950 60000113 df4bbcd0 df4=
bbc80 c04c259d c04c25a0 60000133 ffffffff</div>=0A<div>&gt; [59014.085233]=
 [&lt;c04c28db&gt;] (__irq_svc+0x3b/0x5c) from [&lt;c04c25a0&gt;] (_raw_sp=
in_unlock_irqrestore+0xc/0x10)</div>=0A<div>&gt; [59014.100437] [&lt;c04c2=
5a0&gt;] (_raw_spin_unlock_irqrestore+0xc/0x10) from [&lt;bf9c2089&gt;] (a=
th9k_rx_tasklet+0x290/0x490 [ath9k_htc])</div>=0A<div>&gt; [59014.118267] =
[&lt;bf9c2089&gt;] (ath9k_rx_tasklet+0x290/0x490 [ath9k_htc]) from [&lt;c0=
036d23&gt;] (tasklet_action+0x3b/0x98)</div>=0A<div>&gt; [59014.134132] [&=
lt;c0036d23&gt;] (tasklet_action+0x3b/0x98) from [&lt;c0036709&gt;] (__do_=
softirq+0x99/0x16c)</div>=0A<div>&gt; [59014.147784] [&lt;c0036709&gt;] (_=
_do_softirq+0x99/0x16c) from [&lt;c00369f7&gt;] (irq_exit+0x5b/0x5c)</div>=
=0A<div>&gt; [59014.160653] [&lt;c00369f7&gt;] (irq_exit+0x5b/0x5c) from [=
&lt;c000cfc3&gt;] (handle_IRQ+0x37/0x78)</div>=0A<div>&gt; [59014.173124] =
[&lt;c000cfc3&gt;] (handle_IRQ+0x37/0x78) from [&lt;c00085df&gt;] (omap3_i=
ntc_handle_irq+0x5f/0x68)</div>=0A<div>&gt; [59014.187225] [&lt;c00085df&g=
t;] (omap3_intc_handle_irq+0x5f/0x68) from [&lt;c04c28db&gt;](__irq_svc+0x=
3b/0x5c)</div>=0A<div>&gt;&nbsp; </div>=0A<div>&gt; This bug can be see wi=
th low performance board, such as uniprocessor beagle bone board. Add some=
 debug </div>=0A<div>&gt; message in the ath9k_hif_usb_rx_cb function may =
trigger this bug quickly.</div>=0A<div>&gt;&nbsp; </div>=0A<div>&gt; Signe=
d-off-by: Yuwei Zheng &lt;yuweizheng@139.com&gt;</div>=0A<div>This approac=
h of interaction between tasklet and workqueue processing</div>=0A<div>see=
ms quite complex to me. Wouldn't it be simpler and better to simply</div>=
=0A<div>always run the rx processing code in workqueue context?</div>=0A<d=
iv>That way it can go on processing forever (as long as there is data to b=
e</div>=0A<div>received), while the scheduler ensures that it doesn't inte=
rfere with</div>=0A<div>other critical work on the CPU.</div>=0A<div>&nbsp=
;</div>=0A<div>- Felix</div>=0A</div></blockquote>=0A</body></html>
------=_001_NextPart448136155231_=------



--===============0850616345==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
ath9k-devel mailing list
ath9k-devel@lists.ath9k.org
https://lists.ath9k.org/mailman/listinfo/ath9k-devel

--===============0850616345==--
