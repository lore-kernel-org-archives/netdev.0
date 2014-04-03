From: Willy Tarreau <w@1wt.eu>
Subject: Re: on kernel 2.6.34.15,
 vlan and raw packets can not be received with gfar-enet nic
Date: Thu, 3 Apr 2014 12:01:28 +0200
Message-ID: <20140403100128.GE16158@1wt.eu>
References: <53310F4E.4080104@gmail.com> <533D25D4.4000607@gmail.com>
 <20140403092727.GD16158@1wt.eu> <533D30A1.1060509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Yang, Zhangle \(Eric\)" <Zhangle.Yang@windriver.com>,
 netdev@vger.kernel.org, richardcochran@gmail.com,
 linuxppc-dev@lists.ozlabs.org, guang.yang@windriver.com,
 linux-kernel@vger.kernel.org, yongjun_wei@trendmicro.com.cn,
 sandeep.kumar@freescale.com, Claudiu Manoil <claudiu.manoil@freescale.com>,
 "Tao, Yue" <Yue.Tao@windriver.com>, joe@perches.com, festevam@gmail.com,
 clarocq@gmail.com
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <533D30A1.1060509@gmail.com>
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

SGkgWmh1LAoKT24gVGh1LCBBcHIgMDMsIDIwMTQgYXQgMDU6NTc6NTNQTSArMDgwMCwgemh1eWog
d3JvdGU6Cj4gSSByZWZlcmVuY2UgdGhlIGZvbGxvd2luZyAyIG1haW5saW5lIGNvbW1pdHMuIFRo
ZXNlIDIgY29tbWl0cyBhcmUgYmFzZWQgCj4gb24gdGhlIGN1cnJlbnQga2VybmVsIDMueCBhbmQg
ZXRodG9vbC4KPiBJZiB3ZSBvbmx5IGJhY2twb3J0IHRoZXNlIDIgY29tbWl0cyBvbiBrZXJuZWwg
Mi42LngsIHRoaXMgcHJvYmxlbSB3aWxsIAo+IG5vdCBiZSBmaXhlZCB5ZXQuCgpPSyBmaW5lLCBJ
IGp1c3Qgd2FudGVkIHRoYXQgd2Uga2VlcCB0aGUgcmVmZXJlbmNlIG9mIHRoZXNlIGVxdWl2YWxl
bnQKcGF0Y2hlcyBpbiB0aGUgY29tbWl0IG1lc3NhZ2Ugc28gdGhhdCBpZiBsYXRlciBhIG5ld2Vy
IHBhdGNoIGNoYW5nZXMKYW55dGhpbmcgdGhleSBkaWQsIGF0IGxlYXN0IHdlIGhhdmUgc29tZSBp
bmRpY2F0aW9ucyB0aGF0IHRoZSBjb21taXQKbWlnaHQgYWxzbyBoYXZlIHRvIGJlIHJldmlzaXRl
ZC4KCkknbGwgbWVyZ2UgeW91ciBwYXRjaCBhbmQgcHV0IHRoZXNlIHJlZmVyZW5jZXMgdGhlcmUu
CgpUaGFua3MsCldpbGx5CgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fXwpMaW51eHBwYy1kZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBsaXN0cy5vemxh
YnMub3JnCmh0dHBzOi8vbGlzdHMub3psYWJzLm9yZy9saXN0aW5mby9saW51eHBwYy1kZXY=
