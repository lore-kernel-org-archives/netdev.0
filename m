From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net 1/4] lib/test_bpf: Fix JMP_JSET tests
Date: Tue, 5 Apr 2016 08:57:32 -0700
Message-ID: <5703E06C.5060907@fb.com>
References: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: Daniel Borkmann <daniel@iogearbox.net>, Paul Mackerras <paulus@samba.org>,
 Michael Holzheu <holzheu@linux.vnet.ibm.com>,
 "David S. Miller" <davem@davemloft.net>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
 <linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
 <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

T24gNC81LzE2IDM6MDIgQU0sIE5hdmVlbiBOLiBSYW8gd3JvdGU6Cj4gSk1QX0pTRVQgdGVzdHMg
aW5jb3JyZWN0bHkgdXNlZCBCUEZfSk5FLiBGaXggdGhlIHNhbWUuCj4KPiBDYzogQWxleGVpIFN0
YXJvdm9pdG92IDxhc3RAZmIuY29tPgo+IENjOiBEYW5pZWwgQm9ya21hbm4gPGRhbmllbEBpb2dl
YXJib3gubmV0Pgo+IENjOiAiRGF2aWQgUy4gTWlsbGVyIiA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4K
PiBDYzogQW5hbnRoIE4gTWF2aW5ha2F5YW5haGFsbGkgPGFuYW50aEBpbi5pYm0uY29tPgo+IENj
OiBNaWNoYWVsIEVsbGVybWFuIDxtcGVAZWxsZXJtYW4uaWQuYXU+Cj4gQ2M6IFBhdWwgTWFja2Vy
cmFzIDxwYXVsdXNAc2FtYmEub3JnPgo+IFNpZ25lZC1vZmYtYnk6IE5hdmVlbiBOLiBSYW8gPG5h
dmVlbi5uLnJhb0BsaW51eC52bmV0LmlibS5jb20+CgpHb29kIGNhdGNoLgpGaXhlczogY2ZmYzY0
MmQ5M2Y5ICgidGVzdF9icGY6IGFkZCAxNzMgbmV3IHRlc3RjYXNlcyBmb3IgZUJQRiIpCkFja2Vk
LWJ5OiBBbGV4ZWkgU3Rhcm92b2l0b3YgPGFzdEBrZXJuZWwub3JnPgoKX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMtZGV2IG1haWxpbmcgbGlz
dApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xpc3RzLm96bGFicy5vcmcv
bGlzdGluZm8vbGludXhwcGMtZGV2
